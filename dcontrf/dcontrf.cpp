/* dcontrf.cpp */
static char rcsid[] = "$Id: dcontrf.cpp,v 1.3 2001-06-12 12:42:34 vlad Exp $";
//---------------------------------------------------------------------------

#pragma hdrstop
#ifndef unix
#include <condefs.h>
#endif /* unix */

//---------------------------------------------------------------------------
// Implementation of the phase #3 of neural network control paradigm (NNCP).
// NNCP - neural network control paradigm. (C)opyright by Eliseev Vladimir
//---------------------------------------------------------------------------
// Phase #3: NN optimal controller (in Wiener filter terms) training using
//           NN identifier for error computation.  Input data - u(t), n(t).
//           + prelearned regression NN plant model.
//---------------------------------------------------------------------------

#include <math.h>
#include <stdlib.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>

#include <NaConfig.h>
#include <NaTrFunc.h>
#include <NaNNUnit.h>
#include <NaNNLrn.h>
#include <NaDataIO.h>
#include <NaParams.h>
#include <kbdif.h>

#include "NaNNOCL.h"

//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
  if(2 != argc)
    {
      fprintf(stderr, "Usage: dcontrf ParamFile\n");
      return 1;
    }

  NaOpenLogFile("dcontrf.log");

  try{
    NaParams	par(argv[1]);

    /*************************************************************/
    enum {
      stream_mode,
      file_mode
    }	inp_data_mode;

    if(!strcmp("stream", par("input_kind")))
      {
	NaPrintLog("Using stream reference and noise (transfer functions)\n");
	inp_data_mode = stream_mode;
      }
    else if(!strcmp("file", par("input_kind")))
      {
	NaPrintLog("Using limited reference and noise series (data files)\n");
	inp_data_mode = file_mode;
      }
    else
      {
	NaPrintLog("Bad or undefined input_kind value in .par file\n");
	return 0;
      }

    /*************************************************************/
    // Applied units
    NaTransFunc		refer_tf;
    NaTransFunc		noise_tf;
    NaTransFunc		au_linplant;

    NaConfigPart	*conf_list_linplant[] = { &au_linplant };
    NaConfigFile	conf_file_linplant(";NeuCon transfer", 1, 0);
    conf_file_linplant.AddPartitions(NaNUMBER(conf_list_linplant),
				     conf_list_linplant);

    NaConfigPart	*conf_list_refer[] = { &refer_tf };
    NaConfigFile	conf_file_refer(";NeuCon transfer", 1, 0);
    conf_file_refer.AddPartitions(NaNUMBER(conf_list_refer),
				  conf_list_refer);

    NaConfigPart	*conf_list_noise[] = { &noise_tf };
    NaConfigFile	conf_file_noise(";NeuCon transfer", 1, 0);
    conf_file_noise.AddPartitions(NaNUMBER(conf_list_noise),
				  conf_list_noise);

    // Load plant
    conf_file_linplant.LoadFromFile(par("linplant_tf"));

    // Neural network description
    NaNeuralNetDescr    nnc_descr, nnp_descr;

    // Read neural network from file
    NaNNUnit            au_nnc(nnc_descr), au_nnp(nnp_descr);
    //au_nnc.SetInstance("Plant");

    NaConfigPart        *conf_list_nnc[] = { &au_nnc };
    NaConfigFile        nncfile(";NeuCon NeuralNet", 1, 1);
    nncfile.AddPartitions(NaNUMBER(conf_list_nnc), conf_list_nnc);
    nncfile.LoadFromFile(par("in_nnc_file"));

    NaConfigPart        *conf_list_nnp[] = { &au_nnp };
    NaConfigFile        nnpfile(";NeuCon NeuralNet", 1, 1);
    nnpfile.AddPartitions(NaNUMBER(conf_list_nnp), conf_list_nnp);
    nnpfile.LoadFromFile(par("in_nnp_file"));

    // Interpret NN-C structure
    NaControllerKind	ckind;
    if(au_nnc.descr.nInputsRepeat > 1)
      ckind = NaNeuralContrDelayedE;
    else
      ckind = NaNeuralContrER;

    // Additional log files
    NaDataFile  *nnllog = OpenOutputDataFile(par("trace_file"), bdtAuto, 8);

    nnllog->SetTitle("NN controller preliminary learning (error)");

    nnllog->SetVarName(0, "Mean");
    nnllog->SetVarName(1, "StdDev");
    nnllog->SetVarName(2, "MSE");
    nnllog->SetVarName(3, "MSE(Identif)");

    // Load input data
    int	len;
    switch(inp_data_mode)
      {
      case stream_mode:
	conf_file_refer.LoadFromFile(par("refer_tf"));
	conf_file_noise.LoadFromFile(par("noise_tf"));
	len = atoi(par("stream_len"));
	break;
      case file_mode:
	len = 0;
	break;
      }

    NaNNOptimContrLearn     nnocl(len, ckind);

    // Configure nodes
    nnocl.nncontr.set_transfer_func(&au_nnc);
    nnocl.nnteacher.set_nn(&au_nnc);
    nnocl.plant.set_transfer_func(&au_linplant);
    nnocl.nnplant.set_transfer_func(&au_nnp);
    nnocl.errbackprop.set_nn(&au_nnp);

    // Setpoint and noise
    NaReal	fMean = 0.0, fStdDev = 1.0;

    switch(inp_data_mode)
      {
      case stream_mode:
	nnocl.setpnt_gen.set_generator_func(&refer_tf);
	nnocl.setpnt_gen.set_gauss_distrib(&fMean, &fStdDev);

	nnocl.noise_gen.set_generator_func(&noise_tf);
	nnocl.noise_gen.set_gauss_distrib(&fMean, &fStdDev);
	break;
      case file_mode:
	nnocl.setpnt_inp.set_input_filename(par("in_r"));
	nnocl.noise_inp.set_input_filename(par("in_n"));
	break;
      }

    nnocl.nn_u.set_output_filename(par("out_u"));
    printf("Writing NNC control force to '%s' file.\n", par("out_u"));

    nnocl.nn_y.set_output_filename(par("out_nn_y"));
    printf("Writing NNP identification output to '%s' file.\n",
	   par("out_nn_y"));

    nnocl.on_y.set_output_filename(par("out_ny"));
    printf("Writing plant + noise observation output to '%s' file.\n",
	   par("out_ny"));

    switch(ckind)
      {
      case NaNeuralContrDelayedE:
	break;
      case NaNeuralContrER:
	nnocl.delay_c.set_delay(au_nnc.descr.nInputsRepeat - 1);
	nnocl.delay_c.set_sleep_value(0.0);
	break;
      }

    nnocl.delay.set_delay(au_nnp.descr.nOutputsRepeat - 1);
    nnocl.errfetch.set_output(0);

    // Link the network
    nnocl.link_net();

    // If error changed for less than given value consider stop learning
    // Finish error decrease
    NaReal  fErrPrec = 1e-6;

    // If error started grows, skip checking MSE given number of epochs
    // Skip growing error up to given epochs
    int     nSkipped = 0, nSkipGrowErr = 35;

    // Maximum number of growing error slopes
    int     nNumGrowErr = 35;

    // Configure learning parameters
    nnocl.nnteacher.lpar.eta = 0.01;
    nnocl.nnteacher.lpar.eta_output = 0.004;
    nnocl.nnteacher.lpar.alpha = 0.0;

    // Teach the network iteratively
    NaPNEvent   pnev;
    int         iIter = 0;

#if defined(__MSDOS__) || defined(__WIN32__)
    printf("Press 'q' or 'x' for exit\n");
#endif /* DOS & Win */

    NaReal	fPrevMSE = 0.0;
    int		auf = 0;

    switch(inp_data_mode)
      {
      case stream_mode:
	// Set autoupdate facility
	auf = atoi(par("nnc_auf"));
	nnocl.nnteacher.set_auto_update_freq(auf);
	NaPrintLog("Autoupdate frequency is %d\n", auf);

	pnev = nnocl.run_net();

	if(pneError == pnev)
	  break;

	nnocl.iderrstat.print_stat();
	nnocl.cerrstat.print_stat();
	break;

      case file_mode:
	// Update NN-C at the end of iteration

	do{
	  ++iIter;
	  NaPrintLog("__Iteration_%d__\n", iIter);

	  pnev = nnocl.run_net();

	  if(pneError == pnev)
	    break;

	  nnocl.iderrstat.print_stat();
	  nnocl.cerrstat.print_stat();

	  nnllog->AppendRecord();
	  nnllog->SetValue(nnocl.cerrstat.Mean[0], 0);
	  nnllog->SetValue(nnocl.cerrstat.StdDev[0], 1);
	  nnllog->SetValue(nnocl.cerrstat.RMS[0], 2);
	  nnllog->SetValue(nnocl.iderrstat.RMS[0], 3);

	  printf("Iteration %-4d, MSE=%g  delta=%-g\n",
		 iIter, nnocl.cerrstat.RMS[0],
		 nnocl.cerrstat.RMS[0] - fPrevMSE);

	  if(fPrevMSE != 0.0 && fPrevMSE < nnocl.cerrstat.RMS[0]){
	    if(nSkipped < nSkipGrowErr && nNumGrowErr > 0){
	      --nNumGrowErr;
	      ++nSkipped;
	      printf("Error grows by %g; continue\n",
		     nnocl.cerrstat.RMS[0] - fPrevMSE);
	    }else{
	      nSkipped = 0;
	      if(ask_user_bool("MSE started to grow; stop learning?", true)){
		pnev = pneTerminate;
		break;
	      }
	      if(ask_user_bool("Would you like to change learning parameters?",
			       false)){
		ask_user_lpar(nnocl.nnteacher.lpar);
	      }
	    }
	  }else{
	    nSkipped = 0;

	    if(fPrevMSE != 0.0 &&
	       fabs(fPrevMSE - nnocl.cerrstat.RMS[0]) < fErrPrec){
	      if(ask_user_bool("MSE decrease is very small; stop learning?",
			       true)){
		pnev = pneTerminate;
		break;
	      }
	    }
	  }

	  fPrevMSE = nnocl.cerrstat.RMS[0];

	  nnocl.nnteacher.update_nn();

	}while(pneDead == pnev);
	break;
      }

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

    nncfile.SaveToFile(par("out_nnc_file"));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
