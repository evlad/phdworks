/* dnnplant.cpp */
static char rcsid[] = "$Id: dnnplant.cpp,v 1.2 2002-01-11 21:21:17 vlad Exp $";

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
  if(5 != argc)
    {
      fprintf(stderr, "Usage: dnnplant NNP-File u-File y-File y_nn-File\n");
      return 1;
    }

  NaOpenLogFile("dnnplant.log");

  try{
    // Neural network description
    NaNeuralNetDescr	nn_descr;

    // Read neural network from file
    NaNNUnit		au_nn(nn_descr);
    NaConfigPart        *conf_list[] = { &au_nn };
    NaConfigFile        nnfile(";NeuCon NeuralNet", 1, 1);
    nnfile.AddPartitions(NaNUMBER(conf_list), conf_list);
    nnfile.LoadFromFile(argv[1]);

    NaNNRegrPlantLearn	nnroe(NaEvaluationAlgorithm);	// test

    // Configure nodes
    nnroe.nnplant.set_transfer_func(&au_nn);
    nnroe.delay_u.set_delay(au_nn.descr.nInputsRepeat,
			    au_nn.descr.InputDelays());
    nnroe.delay_y.set_delay(au_nn.descr.nOutputsRepeat,
			    au_nn.descr.OutputDelays());

    NaPNEvent   pnev;

    nnroe.in_u.set_input_filename(argv[2]);
    nnroe.in_y.set_input_filename(argv[3]);
    nnroe.nn_y.set_output_filename(argv[4]);
    nnroe.tr_y.set_output_filename("/tmp/tr_y.dat");

    try{
      nnroe.link_net();
    }
    catch(NaException& ex){
      NaPrintLog("EXCEPTION at linkage phase: %s\n", NaExceptionMsg(ex));
      throw(ex);
    }

    try{
      pnev = nnroe.run_net();

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
    }
    catch(NaException& ex){
      NaPrintLog("EXCEPTION at runtime phase: %s\n", NaExceptionMsg(ex));
      throw(ex);
    }

    printf("MSE=%g (%g)\n", nnroe.statan.RMS[0],
	   nnroe.statan.RMS[0] / nnroe.statan_y.RMS[0]);

    nnroe.statan.print_stat();

  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
