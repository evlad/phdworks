/* dtf.cpp */
static char rcsid[] = "$Id: dobjid.cpp,v 1.1 2001-04-01 20:06:01 vlad Exp $";

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

#include "NaNNROL.h"


/***********************************************************************
 * Train neural net plant identification model.
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(2 != argc)
    {
      fprintf(stderr, "Usage: dobjid ParamFile\n");
      return 1;
    }

  NaOpenLogFile("dobjid.log");

  try{
    NaParams	par(argv[1]);

    // Neural network description
    NaNeuralNetDescr    nn_descr;

    // Read neural network from file
    NaNNUnit            au_nn(nn_descr);
    //au_nn.SetInstance("Object");

    NaConfigPart        *conf_list[] = { &au_nn };
    NaConfigFile        nnfile(";NeuCon NeuralNet", 1, 0);
    nnfile.AddPartitions(NaNUMBER(conf_list), conf_list);
    nnfile.LoadFromFile(par("in_nno_file"));

    // Additional log files
    NaDataFile  *nnllog = OpenOutputDataFile("nno_track.dat");

    nnllog->SetTitle("NN regression object learning");

    nnllog->SetVarName(0, "Mean");
    nnllog->SetVarName(1, "StdDev");
    nnllog->SetVarName(2, "MSE");

    NaNNRegrObjectLearn     nnrol;

    // Configure nodes
    nnrol.nnobject.set_transfer_func(&au_nn);
    nnrol.nnteacher.set_nn(&au_nn);
    nnrol.in_x.set_input_filename(par("in_x"));
    nnrol.in_y.set_input_filename(par("in_y"));
    nnrol.nn_y.set_output_filename(par("nn_y"));
    nnrol.delay.set_delay(au_nn.descr.nOutputsRepeat - 1);

    //nnrol.delay.verbose();
    //nnrol.in_y.verbose();
    //nnrol.trig_x.verbose();
    //nnrol.trig_y.verbose();
    //nnrol.switcher.verbose();
    //nnrol.errcomp.verbose();

    // Link the network
    nnrol.link_net();

    // Configure learning parameters
    nnrol.nnteacher.lpar.eta = atof(par("eta"));
    nnrol.nnteacher.lpar.eta_output = atof(par("eta_output"));
    nnrol.nnteacher.lpar.alpha = atof(par("alpha"));

    ask_user_lpar(nnrol.nnteacher.lpar);

    // Teach the network iteratively
    NaPNEvent   pnev;
    int         iIter = 0;

#if defined(__MSDOS__) || defined(__WIN32__)
    printf("Press 'q' or 'x' for exit\n");
#endif /* DOS & Win */

    au_nn.Initialize();

    NaReal	fPrevMSE = 0.0, fLastMSE = 0.0;
    NaNNUnit	rPrevNN(au_nn);

    // Time chart
    //nnrol.net.time_chart(true);

    do{
      ++iIter;

      pnev = nnrol.run_net();

      if(pneError == pnev || pneTerminate == pnev)
	break;

      nnrol.statan.print_stat();

      nnllog->AppendRecord();
      nnllog->SetValue(nnrol.statan.Mean[0], 0);
      nnllog->SetValue(nnrol.statan.StdDev[0], 1);
      nnllog->SetValue(nnrol.statan.RMS[0], 2);

      printf("Iteration %-4d, MSE=%g", iIter, nnrol.statan.RMS[0]);

      /*
      switch(eState)
	{
	case first_pass:
	  fPrevMSE = nnrol.statan.RMS[0];
	  rPrevNN = au_nn;
	  nnrol.nnteacher.update_nn();
	  break;

	case prev_rejected:
	  break;

	case prev_success:
	  break;
	}
      */
      if(1 == iIter /* 0.0 == fPrevMSE */)
	{
	  fLastMSE = fPrevMSE = nnrol.statan.RMS[0];
	  rPrevNN = au_nn;
	  nnrol.nnteacher.update_nn();
	  printf(" -> teach NN\n");
	}
      else
	{
	  /* next passes */
	  if(fLastMSE < nnrol.statan.RMS[0])
	    {
	      /* growing MSE */
#if 0
	      if(ask_user_bool("MSE started to grow; stop learning?", true)){
		pnev = pneTerminate;
		break;
	      }
	      if(ask_user_bool("Would you like to change learning parameters?",
			       false)){
		ask_user_lpar(nnrol.nnteacher.lpar);
	      }
#else
	      nnrol.nnteacher.lpar.eta /= 2;
	      nnrol.nnteacher.lpar.eta_output /= 2;
	      nnrol.nnteacher.lpar.alpha /= 2;

	      NaPrintLog("Learning parameters: "\
			 "lrate=%g  lrate(out)=%g  momentum=%g\n",
			 nnrol.nnteacher.lpar.eta,
			 nnrol.nnteacher.lpar.eta_output,
			 nnrol.nnteacher.lpar.alpha);

	      au_nn = rPrevNN;
	      fLastMSE = nnrol.statan.RMS[0];
	      nnrol.nnobject.set_transfer_func(&au_nn);
	      nnrol.nnteacher.reset_nn();

	      printf(" -> repeat with (%g, %g, %g)\n",
		     nnrol.nnteacher.lpar.eta,
		     nnrol.nnteacher.lpar.eta_output,
		     nnrol.nnteacher.lpar.alpha);
#endif
	    }
	  else
	    {
	      /* MSE became less */
	      fLastMSE = fPrevMSE = nnrol.statan.RMS[0];
	      rPrevNN = au_nn;
	      nnrol.nnteacher.update_nn();
	      printf(" -> teach NN\n");
	    }
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

    nnfile.SaveToFile(par("out_nno_file"));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
