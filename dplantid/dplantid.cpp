/* dplantid.cpp */
static char rcsid[] = "$Id: dplantid.cpp,v 1.8 2001-12-11 18:35:16 vlad Exp $";

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>

#include <NaConfig.h>
#include <NaTrFunc.h>
#include <NaDataIO.h>
#include <NaParams.h>
#include <kbdif.h>

#include "NaNNRPL.h"


/***********************************************************************
 * Train neural net plant identification model.
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(2 != argc)
    {
      fprintf(stderr, "Usage: dplantid ParamFile\n");
      return 1;
    }

  NaOpenLogFile("dplantid.log");

  try{
    NaParams	par(argv[1]);

    // Neural network description
    NaNeuralNetDescr    nn_descr;

    // Read neural network from file
    NaNNUnit            au_nn(nn_descr);
    //au_nn.SetInstance("Object");

    NaConfigPart        *conf_list[] = { &au_nn };
    NaConfigFile        nnfile(";NeuCon NeuralNet", 1, 1);
    nnfile.AddPartitions(NaNUMBER(conf_list), conf_list);
    nnfile.LoadFromFile(par("in_nnp_file"));

    // Additional log files
    NaDataFile  *nnllog = OpenOutputDataFile(par("trace_file"), bdtAuto, 8);

    nnllog->SetTitle("NN regression plant learning");

    nnllog->SetVarName(0, "Mean");
    nnllog->SetVarName(1, "StdDev");
    nnllog->SetVarName(2, "MSE");

    NaNNRegrPlantLearn	nnrol(NaTrainingAlgorithm, "nnpl");
    NaNNRegrPlantLearn	nnroe(NaEvaluationAlgorithm, "nnpe");

    // Configure nodes
    nnrol.nnteacher.set_nn(&au_nn);

    unsigned	*input_delays = au_nn.descr.InputDelays();
    unsigned	*output_delays = au_nn.descr.OutputDelays();

    int		nLearn, nList_in_u, nList_in_y, nList_nn_y;
    char	**szList_in_u = par("in_u", nList_in_u);
    char	**szList_in_y = par("in_y", nList_in_y);
    char	**szList_nn_y = par("nn_y", nList_nn_y);

    /* nLearn=MAX3(x,y,z) */
    nLearn = nList_in_u;
    if(nLearn < nList_in_y)
      nLearn = nList_in_y;
    if(nLearn < nList_nn_y)
      nLearn = nList_nn_y;

    NaPrintLog("Total %d learning data files\n", nLearn);

    int		nTest, nList_test_in_u, nList_test_in_y, nList_test_nn_y;
    char	**szList_test_in_u = par("test_in_u", nList_test_in_u);
    char	**szList_test_in_y = par("test_in_y", nList_test_in_y);
    char	**szList_test_nn_y = par("test_nn_y", nList_test_nn_y);

    /* nTest=MAX3(x,y,z) */
    nTest = nList_test_in_u;
    if(nTest < nList_test_in_y)
      nTest = nList_test_in_y;
    if(nTest < nList_test_nn_y)
      nTest = nList_test_nn_y;

    NaPrintLog("Total %d testing data files\n", nTest);

    nnrol.nnplant.set_transfer_func(&au_nn);
    nnrol.delay_u.set_delay(au_nn.descr.nInputsRepeat, input_delays);
    nnrol.delay_y.set_delay(au_nn.descr.nOutputsRepeat, output_delays);

    /* Equalize delay to provide synchronous start of delay_u and
       delay_y nodes */
    unsigned	iDelay_u = nnrol.delay_u.get_max_delay();
    unsigned	iDelay_y = nnrol.delay_y.get_max_delay();
    if(iDelay_u < iDelay_y)
      {
	iDelay_u = iDelay_y - iDelay_u;
	iDelay_y = 0;
      }
    else if(iDelay_u > iDelay_y)
      {
	iDelay_y = iDelay_u - iDelay_y;
	iDelay_u = 0;
      }
    else /* if(iDelay_u == iDelay_y) */
      {
	iDelay_y = 0;
	iDelay_u = 0;
      }

    // Provide equalization
    nnrol.delay_y.add_delay(iDelay_y);
    nnrol.delay_u.add_delay(iDelay_u);

    nnroe.nnplant.set_transfer_func(&au_nn);
    nnroe.delay_u.set_delay(au_nn.descr.nInputsRepeat, input_delays);
    nnroe.delay_y.set_delay(au_nn.descr.nOutputsRepeat, output_delays);

    // Provide the same equalization for evaluation petri net
    nnroe.delay_y.add_delay(iDelay_y);
    nnroe.delay_u.add_delay(iDelay_u);

    // Configure learning parameters
    nnrol.nnteacher.lpar.eta = atof(par("eta"));
    nnrol.nnteacher.lpar.eta_output = atof(par("eta_output"));
    nnrol.nnteacher.lpar.alpha = atof(par("alpha"));

    //ask_user_lpar(nnrol.nnteacher.lpar);
    //putchar('\n');

    // Teach the network iteratively
    NaPNEvent   pnev, pnev_test;
    int         iIter = 0, iEpoch = 0, iData;

#if defined(__MSDOS__) || defined(__WIN32__)
    printf("Press 'q' or 'x' for exit\n");
#endif /* DOS & Win */

    //au_nn.Initialize();

    NaReal	fNormMSE, fNormTestMSE;
    NaReal	fPrevMSE = 0.0, fLastMSE = 0.0;
    NaReal	fPrevTestMSE = 0.0;
    int		nGrowingMSE = 0;
    NaNNUnit	rPrevNN(au_nn);
    bool	bTeach, bTeachLinkage = false, bTestLinkage = false;

    /* number of epochs when MSE on test set grows to finish the
       learning */
    int		nFinishOnGrowMSE = atoi(par("finish_on_grow"));

    /* number of epochs to stop learning anyway */
    int		nFinishOnMaxEpoch = atoi(par("finish_max_epoch"));

    /* absolute value of MSE to stop learning if reached */
    NaReal	fFinishOnReachMSE = atof(par("finish_on_value"));

    // Time chart
    //nnrol.net.time_chart(true);

    do{
      ++iIter;

      // teach pass
      for(iData = 0; iData < nLearn; ++iData)
	{
	  NaPrintLog("*** Teach pass: '%s' '%s' '%s' ***\n",
		     szList_in_u[iData],
		     szList_in_y[iData],
		     szList_nn_y[iData]);

	  nnrol.in_u.set_input_filename(szList_in_u[iData]);
	  nnrol.in_y.set_input_filename(szList_in_y[iData]);
	  nnrol.nn_y.set_output_filename(szList_nn_y[iData]);

	  if(!bTeachLinkage)
	    {
	      nnrol.link_net();
	      bTeachLinkage = true;
	    }
	  pnev = nnrol.run_net();

	  if(pneError == pnev || pneTerminate == pnev)
	    break;
	}

      if(pneError == pnev || pneTerminate == pnev)
	break;

      NaPrintLog("*** Teach passed ***\n");
      nnrol.statan.print_stat();

      fNormMSE = nnrol.statan.RMS[0] / nnrol.statan_y.RMS[0];

      printf("Iteration %-4d, MSE=%g (%g)", iIter, nnrol.statan.RMS[0],
	     fNormMSE);

      if(1 == iIter)
	{
	  fLastMSE = fPrevMSE = fNormMSE;
	  rPrevNN = au_nn;
	  nnrol.nnteacher.update_nn();
	  printf(" -> teach NN\n");
	  bTeach = true;
	}
      else
	{
	  /* next passes */
	  if(fLastMSE < fNormMSE)
	    {
	      /* growing MSE on learning set */
	      nnrol.nnteacher.lpar.eta /= 2;
	      nnrol.nnteacher.lpar.eta_output /= 2;
	      nnrol.nnteacher.lpar.alpha /= 2;

	      NaPrintLog("Learning parameters: "\
			 "lrate=%g  lrate(out)=%g  momentum=%g\n",
			 nnrol.nnteacher.lpar.eta,
			 nnrol.nnteacher.lpar.eta_output,
			 nnrol.nnteacher.lpar.alpha);

	      au_nn = rPrevNN;
	      fLastMSE = fNormMSE;
	      nnrol.nnplant.set_transfer_func(&au_nn);
	      nnrol.nnteacher.reset_nn();

	      printf(" -> repeat with (%g, %g, %g)\n",
		     nnrol.nnteacher.lpar.eta,
		     nnrol.nnteacher.lpar.eta_output,
		     nnrol.nnteacher.lpar.alpha);

	      bTeach = false;
	    }
	  else
	    {
	      /* MSE became less */
	      fLastMSE = fPrevMSE = fNormMSE;
	      rPrevNN = au_nn;
	      nnrol.nnteacher.update_nn();
	      printf(" -> teach NN\n");
	      bTeach = true;
	    }
	}

      if(bTeach)
	{
	  ++iEpoch;

	  nnllog->AppendRecord();
	  nnllog->SetValue(nnrol.statan.Mean[0], 0);
	  nnllog->SetValue(nnrol.statan.StdDev[0], 1);
	  nnllog->SetValue(nnrol.statan.RMS[0], 2);

	  // test pass
	  for(iData = 0; iData < nTest; ++iData)
	    {
	      NaPrintLog("*** Test pass: '%s' '%s' '%s' ***\n",
			 szList_test_in_u[iData],
			 szList_test_in_y[iData],
			 szList_test_nn_y[iData]);

	      nnroe.in_u.set_input_filename(szList_test_in_u[iData]);
	      nnroe.in_y.set_input_filename(szList_test_in_y[iData]);
	      nnroe.nn_y.set_output_filename(szList_test_nn_y[iData]);

	      if(!bTestLinkage)
		{
		  nnroe.link_net();
		  bTestLinkage = true;
		}
	      pnev_test = nnroe.run_net();

	      if(pneError == pnev_test || pneTerminate == pnev_test)
		break;
	    }

	  if(pneError == pnev_test || pneTerminate == pnev_test)
	    break;

	  fNormTestMSE = nnroe.statan.RMS[0] / nnroe.statan_y.RMS[0];

	  printf("          Test: MSE=%g (%g)\n", nnroe.statan.RMS[0],
		 nnroe.statan.RMS[0] / nnroe.statan_y.RMS[0]);

	  NaPrintLog("*** Test passed ***\n");
	  nnroe.statan.print_stat();

	  nnllog->SetValue(nnroe.statan.Mean[0], 3);
	  nnllog->SetValue(nnroe.statan.StdDev[0], 4);
	  nnllog->SetValue(nnroe.statan.RMS[0], 5);

	  nnllog->SetValue(fNormMSE, 6);
	  nnllog->SetValue(fNormTestMSE, 7);

	  if(fNormTestMSE < fFinishOnReachMSE)
	    {
	      NaPrintLog("Test MSE reached preset value %g -> stop\n",
			 fFinishOnReachMSE);
	      break;
	    }
	  if(fPrevTestMSE < fNormTestMSE)
	    {
	      /* Start growing */
	      ++nGrowingMSE;
	      if(nGrowingMSE > nFinishOnGrowMSE && nFinishOnGrowMSE > 0)
		{
		  NaPrintLog("Test MSE was growing for %d epoch -> stop\n",
			     nFinishOnGrowMSE);
		  break;
		}
	    }
	  else
	    /* Reset counter */
	    nGrowingMSE = 0;

	  if(nFinishOnMaxEpoch != 0 && iEpoch >= nFinishOnMaxEpoch)
	    {
	      NaPrintLog("Max number of epoch %d is reached -> stop\n",
			 nFinishOnMaxEpoch);
	      break;
	    }

	  fPrevTestMSE = fNormTestMSE;
	}

    }while(pneDead == pnev);

    NaPrintLog("IMPORTANT: net is dead due to ");
    switch(pnev){
    case pneTerminate:
      NaPrintLog("user break.\n");
      break;

    case pneHalted:
      NaPrintLog("internal halt.\n");
      break;

    case pneDead:
      NaPrintLog("data are exhausted.\n");
      break;

    case pneError:
      NaPrintLog("some error occured.\n");
      break;

    default:
      NaPrintLog("unknown reason.\n");
      break;
    }

    delete nnllog;

    nnfile.SaveToFile(par("out_nnp_file"));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
