/* dcsloop.cpp */
static char rcsid[] = "$Id: dcsloop.cpp,v 1.13 2008-05-18 19:06:35 evlad Exp $";

//---------------------------------------------------------------------------
// Implementation of the phase #0 of neural network control paradigm (NNCP).
// NNCP - neural network control paradigm. (C)opyright by Eliseev Vladimir
//---------------------------------------------------------------------------
// Phase #0: preliminary control series obtaining from some traditional
//           control system or traditional control system modeling.
//---------------------------------------------------------------------------

#include <math.h>
#include <stdlib.h>
#include <string.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>
#include <NaConfig.h>
#include <NaCoFunc.h>
#include <NaParams.h>
#include <NaNNUnit.h>

#include "NaCSM.h"



/* Interval to control the 2nd disorder detection interpretation */
int	iDetectInterval = 0;

bool
OnDisorderDetection (void* pUserData, const NaVector& rEvents, NaTimer& rTimer)
{
  static int	nCounter = 0;
  static int	iLastDetection = 0;

  if(rEvents(0) > 0)
    {
      /* count disorder */
      ++nCounter;

      if(iDetectInterval == 0)
	/* terminate execution at the first disorder detection */
	return false;
      else if(iDetectInterval > 0 && nCounter > 1)
	{
	  if(rTimer.CurrentIndex() - iLastDetection > iDetectInterval)
	    /* forget about previous disorder because is was too long
	       ago */
	    nCounter = 0;
	  else
	    /* two disorders inside iDetectInterval, so let's terminate */
	    return false;
	}
    }
  /* let's continue execution */
  return true;
}


//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
  if(argc < 2)
    {
      fprintf(stderr, "Usage: dcsloop ParamFile [Extra name=value pairs]\n");
      return 1;
    }

  NaOpenLogFile("dcsloop.log");

  try{
    NaParams	par(argv[1], argc - 2, argv + 2);

    NaPrintLog("Run dcsloop with %s\n", argv[1]);

    par.ListOfParamsToLog();

    /*************************************************************/
    enum {
      linear_contr,
      neural_contr
    }	contr_kind;

    if(!strcmp("lin", par("contr_kind")))
      {
	NaPrintLog("Using linear controller in control system loop\n");
	contr_kind = linear_contr;
      }
    else if(!strcmp("nnc", par("contr_kind")))
      {
	NaPrintLog("Using neural net controller in control system loop\n");
	contr_kind = neural_contr;
      }
    else
      {
	NaPrintLog("Bad or undefined contr_kind value in .par file\n");
	return 0;
      }

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
    NaCombinedFunc	refer_tf;
    NaCombinedFunc	noise_tf;
    NaCombinedFunc	au_linplant;
    NaCombinedFunc	au_lincontr;
    NaNNUnit		au_nnc, au_nnp;

    // Load plant
    au_linplant.Load(par("linplant_tf"));

    // Initial state
    NaVector	vInitial(1);
    vInitial.init_zero();

    // Type of controller
    NaControllerKind	ckind;

    // Load controller
    switch(contr_kind)
      {
      case linear_contr:
	au_lincontr.Load(par("lincontr_tf"));
	ckind = NaLinearContr;

	vInitial.init_value(atof(par("plant_initial_state")));
	break;
      case neural_contr:
	au_nnc.Load(par("nncontr"));

	// Interpret NN-C structure
	// Default rule
	if(au_nnc.descr.nInputsRepeat > 1)
	  ckind = NaNeuralContrDelayedE;
	else
	  ckind = NaNeuralContrER;
	// Explicit rule
	if(!strcmp(par("nnc_mode"), "e+r"))
	  ckind = NaNeuralContrER;
	else if(!strcmp(par("nnc_mode"), "e+de"))
	  ckind = NaNeuralContrEdE;
	else if(!strcmp(par("nnc_mode"), "e+e+..."))
	  ckind = NaNeuralContrDelayedE;
	if(au_nnc.descr.nInputsRepeat > 1)
	  ckind = NaNeuralContrDelayedE;
	else
	  ckind = NaNeuralContrER;
	break;
      }

    // Load input data
    int	len;
    switch(inp_data_mode)
      {
      case stream_mode:
	refer_tf.Load(par("refer_tf"));
	noise_tf.Load(par("noise_tf"));
	len = atoi(par("stream_len"));
	break;
      case file_mode:
	len = 0;
	break;
      }

    NaControlSystemModel	csm(len, ckind);
    bool			bUseCuSum = par.CheckParam("cusum");

    // Set cummulative sum method is turned on or off
    csm.set_cusum_flag(bUseCuSum);
    NaPrintLog("Cummulative sum detection is %s\n", bUseCuSum? "ON": "OFF");
    if(bUseCuSum)
      {
	csm.dodetect.attach_function(OnDisorderDetection);
      }

    // Setup parameters for NN-P
    if(par.CheckParam("in_nnp_file"))
      {
	//au_nnp.SetInstance("Plant");
	au_nnp.Load(par("in_nnp_file"));
	csm.nnplant.set_nn_unit(&au_nnp);

	// Get NNP delays
	unsigned	*input_delays = au_nnp.descr.InputDelays();
	unsigned	*output_delays = au_nnp.descr.OutputDelays();

	// Configure nodes
	csm.delay_u.set_delay(au_nnp.descr.nInputsRepeat, input_delays);
	csm.delay_y.set_delay(au_nnp.descr.nOutputsRepeat, output_delays);

	unsigned	iDelay_u = csm.delay_u.get_max_delay();
	unsigned	iDelay_y = csm.delay_y.get_max_delay();
	unsigned	iSkip_u = 0, iSkip_y = 0;
	unsigned	iDelay_e, iSkip_e;

	// Skip u or y due to absent earlier values of y or u
	if(iDelay_y >= iDelay_u)
	  {
	    iSkip_u = iDelay_y - iDelay_u + 1;
	  }
	else /* if(iDelay_u > iDelay_y) */
	  {
	    iSkip_y = iDelay_u - iDelay_y - 1;
	  }
	iDelay_e = iDelay_y + iSkip_y;
	iSkip_e = 1 + iDelay_e;

	csm.skip_u.set_skip_number(iSkip_u);
	csm.skip_y.set_skip_number(iSkip_y);

	// Additional delay for target value
	//csm.skip_e.set_skip_number(1 + iSkip_e);

	csm.skip_ny.set_skip_number(1 + iSkip_e);
	csm.fill_nn_y.set_fill_number(iSkip_e);

	NaPrintLog("delay_u=%d,  skip_u=%d\n", iDelay_u, iSkip_u);
	NaPrintLog("delay_y=%d,  skip_y=%d\n", iDelay_y, iSkip_y);
	NaPrintLog("delay_e=%d,  skip_e=%d\n", iDelay_e, iSkip_e);

	csm.nn_y.set_output_filename(par("out_nn_y"));
	NaPrintLog("Writing NNP identification output to '%s' file.\n",
		   par("out_nn_y"));

	csm.nn_e.set_output_filename(par("out_nn_e"));
	NaPrintLog("Writing NNP identification error to '%s' file.\n",
		   par("out_nn_e"));
      }

    // Link the network
    csm.link_net();

    // Configure nodes
    csm.chkpnt_r.set_output_filename(par("out_r"));
    csm.chkpnt_e.set_output_filename(par("out_e"));
    csm.chkpnt_u.set_output_filename(par("out_u"));
    csm.chkpnt_n.set_output_filename(par("out_n"));
    csm.chkpnt_y.set_output_filename(par("out_y"));
    csm.chkpnt_ny.set_output_filename(par("out_ny"));

    if(bUseCuSum)
      csm.cusum_out.set_output_filename(par("cusum"));
      
    // Setpoint and noise
    NaReal	fMean = 0.0, fStdDev = 1.0;

    switch(inp_data_mode)
      {
      case stream_mode:
	csm.setpnt_gen.set_generator_func(&refer_tf);
	csm.setpnt_gen.set_gauss_distrib(&fMean, &fStdDev);

	csm.noise_gen.set_generator_func(&noise_tf);
	csm.noise_gen.set_gauss_distrib(&fMean, &fStdDev);
	break;
      case file_mode:
	csm.setpnt_inp.set_input_filename(par("in_r"));
	csm.noise_inp.set_input_filename(par("in_n"));
	break;
      }

    // Plant
    csm.set_initial_state(vInitial);
    csm.plant.set_transfer_func(&au_linplant);

    // Controller
    switch(contr_kind)
      {
      case linear_contr:
	csm.controller.set_transfer_func(&au_lincontr);
	break;
      case neural_contr:
	csm.controller.set_transfer_func(&au_nnc);
	break;
      }

    // Setup parameters for CUSUM (disorder detection)
    if(bUseCuSum)
      {
	csm.cusum.setup(atof(par("sigma0")), atof(par("sigma1")),
			atof(par("h_sol")), atof(par("k_const")));

	if(par.CheckParam("detect_interval"))
	  iDetectInterval = atoi(par("detect_interval"));
      }

    NaPNEvent   pnev = csm.run_net();

    printf("\nMean squared error=%g\n", csm.statan_e.RMS[0]);

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

#if 0
    // Maximum absolute value of an set point
    NaReal  aMax_u;
    if(fabs(csm.statan_u.Min[0]) > fabs(csm.statan_u.Max[0])){
      aMax = csm.statan_u.Min[0];
    }else{
      aMax = csm.statan_u.Max[0];
    }
#endif

    csm.statan_r.print_stat("Statistics of set point:");
    csm.statan_e.print_stat("Statistics of error:");
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
    fprintf(stderr, "EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
