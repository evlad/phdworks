/* wmr0.cpp */
static char rcsid[] = "$Id$";

#include <stdio.h>
#include <stdlib.h>

#include <NaDataIO.h>
#include <NaWMR.h>


int
main (int argc, char* argv[])
{
  if(argc < 5)
    {
      fprintf(stderr, "Error: need at least 4 arguments\n");
      printf("Usage: wmr0 wmr.par DeltaTime InSeries OutSeries "	\
	     " [rest parameters]\n"					\
	     "InSeries:\n"						\
	     " x[1] - left DC motor voltage\n"				\
	     " x[2] - right DC motor voltage\n"				\
	     "OutSeries:\n"						\
	     " y[1] - time samples\n"					\
	     " y[2] - x coordinate\n"					\
	     " y[3] - y coordinate\n"					\
	     " y[4] - directional angle\n"				\
	     " y[5] - angle velocity\n"					\
	     " y[6] - direct velocity\n"				\
	     " y[7] - left wheel torque\n"				\
	     " y[8] - right wheel torque\n"
	     );
      return 1;
    }

  try{
    const char	*szWMRParFile = argv[1];
    NaReal	fDt = atof(argv[2]);
    const char	*szInFile = argv[3];
    const char	*szOutFile = argv[4];

    NaParams	par(szWMRParFile, argc - 5, argv + 5);

    NaPrintLog("Run wmr0 with %s\n", szWMRParFile);

    par.ListOfParamsToLog();
    NaPrintLog("Sampling rate is %g s\n", fDt);
    if(fDt <= 0.0){
      fprintf(stderr, "Error: bad samping rate %g s\n", fDt);
      return 3;
    }

    NaWMR	wmr;
    wmr.Timer().SetSamplingRate(fDt);
    wmr.SetParameters(par);

    NaDataFile	*dfIn = OpenInputDataFile(szInFile);
    NaDataFile	*dfOut = OpenOutputDataFile(szOutFile, bdtAuto,
					    1 + NaWMR::__state_dim);

    dfIn->GoStartRecord();
    wmr.Reset();
    do{
      NaReal	fIn[NaWMR::__input_dim], fOut[NaWMR::__state_dim];

      for(int i = 0; i < NaWMR::__input_dim; ++i)
	fIn[i] = dfIn->GetValue(i);

      wmr.Function(fIn, fOut);

      dfOut->AppendRecord();

      dfOut->SetValue(wmr.Timer().CurrentTime(), 0);
      for(int i = 0; i < NaWMR::__state_dim; ++i)
	dfOut->SetValue(fOut[i], i+1);

      wmr.Timer().GoNextTime();
    }while(dfIn->GoNextRecord());

    delete dfOut;
    delete dfIn;

  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
    return 2;
  }

  return 0;
}
