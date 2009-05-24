/* acs_simple.cpp */

#include <stdio.h>
#include <stdlib.h>

#include <NaCoFunc.h>
#include <NaPNRand.h>
#include <NaPNFOut.h>
#include <NaPNCuSu.h>
#include <NaPNWatc.h>


/** \file Simple test for algorithm of cummulative sum used to detect
    change of standard deviation of random process.

    Usage: acs_simple Process.cof StdDev0 StdDev1 SolLevel \
                      [ConstK [ImagingPoint.dat]]

    Example: ./acs_simple test.cof 1 2 5
 */


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
	      "Usage: acs_simple Process.cof StdDev0 StdDev1 SolLevel\n"\
	      "                  [ConstK [ImagingPoint.dat]]\n");
      return 1;
    }

  /*
   *  Setup parameters
   */

  try{
    /** random process */
    NaPNRandomGen	proc("proc");
    NaCombinedFunc	proc_cof;

    proc_cof.Load(argv[1]);
    proc.set_generator_func(&proc_cof);

    NaReal	fMean = 0.0, fStdDev = 1.0;
    proc.set_gauss_distrib(&fMean, &fStdDev);

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

      net.link(&proc.y, &cusum.x);
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
