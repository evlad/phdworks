/* dstat.cpp */
static char rcsid[] = "$Id: dstat.cpp,v 1.1 2001-05-05 18:51:14 vlad Exp $";

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>

#include <NaDataIO.h>


/***********************************************************************
 * Read discrete signals and prepare mean and std.dev. series on output.
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(argc == 1)
    {
      fprintf(stderr, "Error: need arguments\n");
      fprintf(stderr,
	      "Usage: dstat [ColNum] SignalSeries1 [SignalSeries2 ...]\n");
      return 1;
    }

  char		*p, **args = argv + 1;
  int		i, argn = argc - 1, iCol;
  NaDataFile	**dfSeries = new NaDataFile*[argn];

  NaOpenLogFile("dstat.log");

  iCol = strtol(argv[1], &p, 10);
  if(argv[1] == p)
    iCol = 0;	/* default column */
  else
    {
      --iCol;	/* index instead of number */
      args = argv + 2;
      --argn;
    }

  for(i = 0; i < argn; ++i)
    {
      try{
	dfSeries[i] = OpenInputDataFile(args[i]);
	if(NULL != dfSeries[i])
	  dfSeries[i]->GoStartRecord();
      }
      catch(NaException& ex){
	NaPrintLog("Failed to open '%s' due to %s\n",
		   args[i], NaExceptionMsg(ex));
	dfSeries[i] = NULL;
      }
    }

  try{
    unsigned	nVal;
    NaReal	fVal, fSum, fSumSq;
    bool	bEOF = false;
    do{
      nVal = 0;
      fSum = 0.0;
      fSumSq = 0.0;

      for(i = 0; i < argn; ++i)
	if(NULL != dfSeries[i])
	  {
	    ++nVal;
	    fVal = dfSeries[i]->GetValue(iCol);
	    fSum += fVal;
	    fSumSq += fVal * fVal;
	    if(!dfSeries[i]->GoNextRecord())
	      bEOF = true;
	  }

      printf("%g %g\n", fSum/nVal, sqrt(fSumSq/nVal - (fSum*fSum)/(nVal*nVal)));

    }while(!bEOF);

    for(i = 0; i < argn; ++i)
      delete dfSeries[i];

    delete dfSeries;
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
