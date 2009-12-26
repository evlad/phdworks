/* acs_simple.cpp */
static char rcsid[] = "$Id$";

#include <stdio.h>
#include <stdlib.h>

#include <NaDataIO.h>
#include <NaCoFunc.h>
#include <NaPNRand.h>
#include <NaPNFOut.h>
#include <NaPNCuSu.h>
#include <NaPNWatc.h>
#include <NaPNFIn.h>


/** \file Simple test for algorithm of cummulative sum used to detect
    change of standard deviation of random process.

    Usage: acs_simple [Process.cof|Series.dat] StdDev0 StdDev1 SolLevel \
                      [ConstK [ImagingPoint.dat]]

    Example: ./acs_simple test.cof 1 2 5

    Example: ACS_EVENTS=3 ./acs_simple test.cof 1 2 5 0 acs.dat
 */


/** Number of detection events to log. */
int	iCounter = -1;


/** Disorder detector after cummulative sum node */
bool
logger (void* dummy, const NaVector& data, NaTimer& timer)
{
  if(data.dim() == 0)
    return true;

  if(data(0) > 0.5)
    {
      printf("disorder is detected (%g) at time %g (sample %d)\n",
	     data(0), timer.CurrentTime(), timer.CurrentIndex());

      --iCounter;
      if(iCounter == 0)
	/* stop execution only if iCounter reached zero */
	return false;
    }
  return true;
}


int
main (int argc, char* argv[])
{
  if(argc < 5)
    {
      fprintf(stderr,
	      "Usage: acs_simple [Process.cof|Series.dat] StdDev0 StdDev1 SolLevel\n"\
	      "                  [ConstK [ImagingPoint.dat]]\n"\
	      "ACS_EVENTS=N - number of disorder events to detect\n");
      return 1;
    }

  if(NULL != getenv("ACS_EVENTS"))
    {
      iCounter = atoi(getenv("ACS_EVENTS"));
      NaPrintLog("Maximum number of disorder events to detect is %d\n",
		 iCounter);
    }

  /*
   *  Setup parameters
   */

  try{
    /** type of process definition: series file or function */
    enum { Series, Function }	eType;
    /** random process */
    NaPNRandomGen	proc("proc");
    NaCombinedFunc	proc_cof;
    NaPNFileInput	series;

    if(ffUnknown == NaDataFile::GuessFileFormatByName(argv[1]) &&
       ffUnknown == NaDataFile::GuessFileFormatByMagic(argv[1]))
      eType = Function;
    else
      eType = Series;

    NaReal	fMean = 0.0, fStdDev = 1.0;
    switch(eType)
      {
      case Function:
	proc_cof.Load(argv[1]);
	proc.set_generator_func(&proc_cof);
	proc.set_gauss_distrib(&fMean, &fStdDev);
	break;

      case Series:
	series.set_input_filename(argv[1]);
	break;
      }

    /** cummulative sum detector */
    NaPNCuSum		cusum("cusum");
    if(argc == 5)
      cusum.setup(atof(argv[2]), atof(argv[3]), atof(argv[4]));
    else
      cusum.setup(atof(argv[2]), atof(argv[3]), atof(argv[4]), atof(argv[5]));

    /** imaging point tracker */
    NaPNFileOutput	imgpnt("imgpnt");
    imgpnt.set_output_filename(argc > 6? argv[6]: "/dev/null");

    /** disorder logger */
    NaPNWatcher		watcher("watcher");
    watcher.attach_function(logger);

    /*
     *  Link Petri network
     */
    try{
      NaPetriNet	net("acs_simlpe");

      net.set_timing_node(&watcher);

    switch(eType)
      {
      case Function:
	net.link(&proc.y, &cusum.x);
	break;

      case Series:
	net.link(&series.out, &cusum.x);
	break;
      }
      net.link(&cusum.d, &watcher.events);
      net.link(&cusum.sum, &imgpnt.in);

      if(!net.prepare()){
	fprintf(stderr, "IMPORTANT: verification failed!\n");
      }
      else{
	NaPNEvent	pnev;

	do{
	  pnev = net.step_alive();
	}while(pneAlive == pnev);

	net.terminate();
      }

    }
    catch(NaException& ex){
      fprintf(stderr, "EXCEPTION while petri net execution: %s\n",
	      NaExceptionMsg(ex));
      return 3;
    }
  }
  catch(NaException& ex){
    fprintf(stderr, "EXCEPTION while setting up parameters: %s\n",
	    NaExceptionMsg(ex));
    return 2;
  }

  return 0;
}
