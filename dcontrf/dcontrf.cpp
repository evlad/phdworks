/* dcontrf.cpp */
static char rcsid[] = "$Id: dcontrf.cpp,v 2.4 2002-02-14 14:19:58 vlad Exp $";
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
//           NN identifier for error computation.  Input data - r(t), n(t).
//           + prelearned regression NN plant model.
//---------------------------------------------------------------------------

#include <math.h>
#include <ctype.h>
#include <string.h>
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
NaReal	fPrevMSEc = 0.0, fPrevMSEi = 0.0;

void
PrintLog (int iAct, void* pData)
{
  NaNNOptimContrLearn	&nnocl = *(NaNNOptimContrLearn*)pData;

  printf("%4d: Control MSE=%7.4f delta=%+9.7f"\
	 "  Ident.MSE=%7.4f delta=%+9.7f\n", iAct,
	 nnocl.cerrstat.RMS[0], nnocl.cerrstat.RMS[0] - fPrevMSEc,
	 nnocl.iderrstat.RMS[0], nnocl.iderrstat.RMS[0] - fPrevMSEi);

  fPrevMSEc = nnocl.cerrstat.RMS[0];
  fPrevMSEi = nnocl.iderrstat.RMS[0];
}


//---------------------------------------------------------------------------
void
ParseHaltCond (NaPNStatistics& pnstat, char* parvalue)
{
  char	*token;

  for(token = strtok(parvalue, ";");
      NULL != token;
      token = strtok(NULL, ";"))
    {
      int	sign;
      char	*stend;

      char	*stname = token;

      // skip leading spaces
      while(*stname != '\0')
	{
	  if(!isspace(*stname))
	    break;
	  ++stname;
	}

      stend = stname;

      // find end of statistics name
      while(*stend != '\0')
	{
	  if(!isalpha(*stend))
	    break;
	  ++stend;
	}

      char	*op = stend;

      // skip leading spaces
      while(*op != '\0')
	{
	  if(!isspace(*op))
	    break;
	  ++op;
	}

      switch(*op)
	{
	case '<':
	  sign = LESS_THAN;
	  break;
	case '=':
	  sign = EQUAL_TO;
	  break;
	case '>':
	  sign = GREATER_THAN;
	  break;
	default:
	  // skip 
	  NaPrintLog("Unknown condition operator '%c' -> skip token '%s'\n",
		     *op, token);
	  continue;
	}

      *stend = '\0';

      int	stat_id = NaStatTextToId(stname);
      NaReal	value = atof(1 + op);

      NaPrintLog("Halt rule is: %s %c %g\n",
		 NaStatIdToText(stat_id),
		 (sign < 0)?'<':((sign > 0)?'>':'='),
		 value);

      pnstat.halt_condition(stat_id, sign, value);
    }
}


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

    NaConfigPart	*conf_list_refer[] = { &refer_tf };
    NaConfigFile	conf_file_refer(";NeuCon transfer", 1, 0);
    conf_file_refer.AddPartitions(NaNUMBER(conf_list_refer),
				  conf_list_refer);

    NaConfigPart	*conf_list_noise[] = { &noise_tf };
    NaConfigFile	conf_file_noise(";NeuCon transfer", 1, 0);
    conf_file_noise.AddPartitions(NaNUMBER(conf_list_noise),
				  conf_list_noise);

    // Load plant
    au_linplant.Load(par("linplant_tf"));

    // Read neural network from file
    NaNNUnit            au_nnc, au_nnp;
    //au_nnc.SetInstance("Plant");

    au_nnc.Load(par("in_nnc_file"));
    au_nnp.Load(par("in_nnp_file"));

    // Get NNP delays
    unsigned	*input_delays = au_nnp.descr.InputDelays();
    unsigned	*output_delays = au_nnp.descr.OutputDelays();

    // Interpret NN-C structure
    NaControllerKind	ckind;
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

    NaNNOptimContrLearn     nnocl(len, ckind, "nncfl");

    // Configure nodes
    nnocl.delay_u.set_delay(au_nnp.descr.nInputsRepeat, input_delays);
    nnocl.delay_y.set_delay(au_nnp.descr.nOutputsRepeat, output_delays);

    unsigned	iDelay_u = nnocl.delay_u.get_max_delay();
    unsigned	iDelay_y = nnocl.delay_y.get_max_delay();
    unsigned	iSkip_u, iSkip_y;
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

    nnocl.skip_u.set_skip_number(iSkip_u);
    nnocl.skip_y.set_skip_number(iSkip_y);

    // Additional delay for target value
    nnocl.skip_e.set_skip_number(1 + iSkip_e);

    nnocl.skip_ny.set_skip_number(1 + iSkip_e);
    nnocl.fill_nn_y.set_fill_number(iSkip_e);

    printf("delay_u=%d,  skip_u=%d\n", iDelay_u, iSkip_u);
    printf("delay_y=%d,  skip_y=%d\n", iDelay_y, iSkip_y);
    printf("delay_e=%d,  skip_e=%d\n", iDelay_e, iSkip_e);

    nnocl.plant.set_transfer_func(&au_linplant);
    nnocl.nncontr.set_nn_unit(&au_nnc);
    nnocl.nnteacher.set_nn(&nnocl.nncontr, iSkip_e);
    nnocl.nnplant.set_nn_unit(&au_nnp);
    nnocl.errbackprop.set_nn(&nnocl.nnplant);

    // u[0] - actual controller force
    nnocl.errfetch.set_output(0);

    // Setpoint and noise
    NaReal	fMean = 0.0, fStdDev = 1.0;

    // Log files with statistics (file_mode)
    NaDataFile	*dfCErr = NULL, *dfIdErr = NULL;

    printf("Writing control error statistics to '%s' file.\n",
	   par("cerr_trace_file"));
    printf("Writing identification error statistics to '%s' file.\n",
	   par("iderr_trace_file"));

    nnocl.c_in.set_output_filename(par("c_in"));
    nnocl.p_in.set_output_filename(par("p_in"));

    switch(inp_data_mode)
      {
      case stream_mode:
	nnocl.setpnt_gen.set_generator_func(&refer_tf);
	nnocl.setpnt_gen.set_gauss_distrib(&fMean, &fStdDev);

	nnocl.noise_gen.set_generator_func(&noise_tf);
	nnocl.noise_gen.set_gauss_distrib(&fMean, &fStdDev);

	nnocl.setpnt_out.set_output_filename(par("out_r"));
	printf("Writing reference signal to '%s' file.\n", par("out_r"));

	nnocl.noise_out.set_output_filename(par("out_n"));
	printf("Writing pure noise signal to '%s' file.\n", par("out_n"));

	nnocl.cerr_fout.set_output_filename(par("cerr_trace_file"));
	nnocl.iderr_fout.set_output_filename(par("iderr_trace_file"));
	break;

      case file_mode:
	nnocl.setpnt_inp.set_input_filename(par("in_r"));
	nnocl.noise_inp.set_input_filename(par("in_n"));

	dfCErr = OpenOutputDataFile(par("cerr_trace_file"),
				    bdtAuto, NaSI_number);
	dfIdErr = OpenOutputDataFile(par("iderr_trace_file"),
				     bdtAuto, NaSI_number);

	// Need only the last data portion; all previous must be skipped
	nnocl.cerr_qout.set_queue_limit(0);
	nnocl.iderr_qout.set_queue_limit(0);
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
      case NaNeuralContrEdE:
	// Nothing special
	break;
      case NaNeuralContrER:
	nnocl.delay_c.set_delay(au_nnc.descr.nInputsRepeat - 1);
	nnocl.delay_c.set_sleep_value(0.0);
	break;
      }

    // Link the network
    nnocl.link_net();

    // If error changed for less than given value consider stop learning
    // Finish error decrease
    NaReal  fErrPrec = atof(par("finish_decrease"));

    // If error started grows, skip checking MSE given number of epochs
    // Skip growing error up to given epochs
    int     nSkipped = 0, nSkipGrowErr = atoi(par("skip_growing"));

    // Maximum number of growing error slopes
    int     nNumGrowErr = atoi(par("finish_on_grow"));

    // Configure learning parameters
    nnocl.nnteacher.lpar.eta = atof(par("eta"));
    nnocl.nnteacher.lpar.eta_output = atof(par("eta_output"));
    nnocl.nnteacher.lpar.alpha = atof(par("alpha"));

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
	nnocl.cerrstat.set_floating_gap(auf);
	nnocl.iderrstat.set_floating_gap(auf);

	ParseHaltCond(nnocl.cerrstat, par("finish_cerr_cond"));
	ParseHaltCond(nnocl.iderrstat, par("finish_iderr_cond"));

	nnocl.nnteacher.set_auto_update_proc(PrintLog, &nnocl);

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

	  // Store error statistics
	  int	i;
	  NaReal	buf[NaSI_number] = {10., 20., 30.};

	  dfCErr->AppendRecord();
	  nnocl.cerr_qout.get_data(buf);
	  for(i = 0; i < NaSI_number; ++i)
	    dfCErr->SetValue(buf[i], i);

	  dfIdErr->AppendRecord();
	  nnocl.iderr_qout.get_data(buf);
	  for(i = 0; i < NaSI_number; ++i)
	    dfIdErr->SetValue(buf[i], i);

	  if(pneError == pnev || pneTerminate == pnev || pneHalted == pnev)
	    break;

	  PrintLog(iIter, &nnocl);

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

    char	*szFirst = "IMPORTANT: net is dead due to";
    char	*szSecond = NULL;
    switch(pnev){
    case pneTerminate:
      szSecond = "user break.";
      break;

    case pneHalted:
      szSecond = "internal halt.";
      break;

    case pneDead:
      szSecond = "data are exhausted.";
      break;

    case pneError:
      szSecond = "some error occured.";
      break;

    default:
      szSecond = "unknown reason.";
      break;
    }

    NaPrintLog("%s %s\n", szFirst, szSecond);
    printf("%s %s\n", szFirst, szSecond);

    delete dfCErr;
    delete dfIdErr;

    au_nnc.Save(par("out_nnc_file"));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
