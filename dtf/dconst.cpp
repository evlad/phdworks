/* dconst.cpp */
static char rcsid[] = "$Id: dconst.cpp,v 1.1 2002-03-09 21:05:16 vlad Exp $";

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
 * Check for hypothesis of constant mean value (no trend).  Read one
 * discrete signal series and perform "median series criteria".
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(argc != 2)
    {
      fprintf(stderr, "Usage: dconst SignalSeries\n");
      return 1;
    }

  char	*signal_file = argv[1];

  NaOpenLogFile("dconst.log");

  try{
    NaVector	series, hi_lo;
    NaDataFile	*dfSignal = OpenInputDataFile(signal_file);

    int		i, N = dfSignal->CountOfRecord();
    series.new_dim(N);

    for(dfSignal->GoStartRecord(), i = 0;
	i < N;
	dfSignal->GoNextRecord(), ++i)
      {
	series[i] = dfSignal->GetValue();
      }

    NaReal	fMedian = series.median();
    hi_lo.new_dim(N);

    /* hi_lo is a sequence of +1, -1 and 0 */
    for(i = 0; i < N; ++i){
      if(series(i) < fMedian)
	hi_lo[i] = -1.;
      else if(series(i) > fMedian)
	hi_lo[i] = 1.;
      else
	hi_lo[i] = 0.;

      NaPrintLog("%c\t%g\n",
		 hi_lo[i]<0.?'-':(hi_lo[i]>0.?'+':'.'), series(i));
    }

    NaPrintLog("Median is %g\n", fMedian);

    /* nu is a common number of "+" or "-" series;
       tau is a length of the longest series. */
    int	nu = 0, tau = 0;

    NaReal	fPrev = 0.;	/* sign of the current series */
    int		len = 0;	/* length of the current series */

    /* find nu and tau */
    for(i = 0; i < N; ++i){

      if(hi_lo(i) != fPrev){
	/* finish previous series */
	if(0.0 != fPrev){
	  ++nu;
	  if(len + 1 > tau)
	    tau = len + 1;
	  len = 0;
	}
      }

      if(hi_lo(i) == fPrev){
	/* series of "+" or "-" continues */
	if(hi_lo(i) != 0.0)
	  ++len;
	/* don't count zeros */
      }

      /* remember this value */
      fPrev = hi_lo(i);
    }

    if(0.0 != fPrev){
      /* finish last series */
      ++nu;
      if(len + 1 > tau)
	tau = len + 1;
    }

    NaPrintLog("Common number of \"+\" or \"-\" series:\t\t%d\n", nu);
    NaPrintLog("Length of the longest \"+\" or \"-\" series:\t%d\n", tau);

    /* test for hypothesis */
    NaReal	nu_95 = 0.5 * (N + 2 - 1.96 * sqrt(N - 1));
    NaReal	tau_05 = 1.43 * log(N + 1);

    NaPrintLog("nu(95%)=%g\n", nu_95);
    NaPrintLog("tau(5%)=%g\n", tau_05);

    printf("Constant mean hypothesis is %s.\n",
	   (nu > (int)nu_95 && tau < (int)tau_05)? "true": "false");

    delete dfSignal;
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
