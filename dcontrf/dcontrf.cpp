/* dcontrf.cpp */
static char rcsid[] = "$Id: dcontrf.cpp,v 1.10 2001-12-16 17:25:30 vlad Exp $";
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
	conf_file_refer.LoadFromFile(par("refer_tf"));
	conf_file_noise.LoadFromFile(par("noise_tf"));
	len = atoi(par("stream_len"));
	break;
      case file_mode:
	len = 0;
	break;
      }

    NaNNOptimContrLearn     nnocl(len, ckind, "nncfl");

    // Configure nodes
    nnocl.plant.set_transfer_func(&au_linplant);
    nnocl.nncontr.set_nn_unit(&au_nnc);
    nnocl.nnteacher.set_nn(&nnocl.nncontr/*&au_nnc*/);
    nnocl.nnplant.set_nn_unit(&au_nnp);
    nnocl.errbackprop.set_nn(&nnocl.nnplant/*&au_nnp*/);

    nnocl.delay_u.set_delay(au_nnp.descr.nInputsRepeat, input_delays);
    nnocl.delay_y.set_delay(au_nnp.descr.nOutputsRepeat, output_delays);

    /* Equalize delay to provide synchronous start of delay_u and
       delay_y nodes */
    unsigned	iDelay_u = nnocl.delay_u.get_max_delay();
    unsigned	iDelay_y = nnocl.delay_y.get_max_delay();
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

    // Provide delay equalization on plant input
    nnocl.delay_y.add_delay(iDelay_y);
    nnocl.delay_u.add_delay(iDelay_u);

    nnocl.errfetch.set_output(0);	/* u[0] - actual controller force */

    // Setpoint and noise
    NaReal	fMean = 0.0, fStdDev = 1.0;

    // Log files with statistics (file_mode)
    NaDataFile	*dfCErr = NULL, *dfIdErr = NULL;

    printf("Writing control error statistics to '%s' file.\n",
	   par("cerr_trace_file"));
    printf("Writing identification error statistics to '%s' file.\n",
	   par("iderr_trace_file"));

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

	  if(pneError == pnev)
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

    delete dfCErr;
    delete dfIdErr;

    nncfile.SaveToFile(par("out_nnc_file"));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
