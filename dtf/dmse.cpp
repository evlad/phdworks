/* dmse.cpp */
static char rcsid[] = "$Id: dmse.cpp,v 1.1 2001-04-01 19:40:16 vlad Exp $";

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>

#include <NaConfig.h>
#include <NaDataIO.h>


/***********************************************************************
 * Read discrete signal and observed output and compute mean squared
 * error.
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(argc != 3)
    {
      fprintf(stderr, "Error: need 2 arguments\n");
      fprintf(stderr,
	      "Usage: DMSE_DELAY=Delay dmse SignalSeries ObservSeries\n");
      return 1;
    }

  char	*signal_file = argv[1];
  char	*observed_file = argv[2];

  NaOpenLogFile("dmse.log");

  try{
    NaDataFile	*dfSignal = OpenInputDataFile(signal_file);
    NaDataFile	*dfObserved = OpenInputDataFile(observed_file);
    NaReal	fMSE = 0.;
    unsigned	nSamples = 0;

    dfSignal->GoStartRecord();
    dfObserved->GoStartRecord();

    char *p = getenv("DMSE_DELAY");
    if(NULL != p)
      {
	int	i, n = atoi(p);
	for(i = 0; i < n; ++i)
	  /* avoid delay between signal and observation */
	  dfObserved->GoNextRecord();
      }

    do{
      NaReal	fSignal, fObserved;
      fSignal = dfSignal->GetValue();
      fObserved = dfObserved->GetValue();

      fMSE += (fSignal - fObserved) * (fSignal - fObserved);
      ++nSamples;
    }while(dfSignal->GoNextRecord() &&
	   dfObserved->GoNextRecord());

    fMSE = /*sqrt(*/fMSE/*)*/ / nSamples;

    printf("%g\n", fMSE);

    delete dfObserved;
    delete dfSignal;
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
