/* NaNNRPL.cpp */
static char rcsid[] = "$Id: NaNNRPL.cpp,v 1.8 2001-12-17 21:50:55 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include <NaExcept.h>
#include "NaNNRPL.h"


//---------------------------------------------------------------------------
// Create the object
NaNNRegrPlantLearn::NaNNRegrPlantLearn (NaAlgorithmKind akind,
					const char* szNetName)
: net(szNetName), eAlgoKind(akind),
  in_u("in_u"),
  in_y("in_y"),
  nn_y("nn_y"),
  nnplant("nnplant"),
  nnteacher("nnteacher"),
  bus("bus"),
  errcomp("errcomp"),
  statan("statan"),
  statan_y("statan_y"),
  delay_u("delay_u"),
  delay_y("delay_y"),
  delay_yt("delay_yt"),
  skip_u("skip_u"),
  skip_y("skip_y"),
  skip_yt("skip_yt"),
  switch_y("switch_y")
{
    // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the object
NaNNRegrPlantLearn::~NaNNRegrPlantLearn ()
{
    // Nothing to do
}


//---------------------------------------------------------------------------

////////////////////
// Network phases //
////////////////////

//---------------------------------------------------------------------------
// Link the network (tune the net before)
void
NaNNRegrPlantLearn::link_net ()
{
    try{
	// Link the network
	net.link(&in_u.out, &skip_u.in);
	net.link(&skip_u.out, &delay_u.in);
	net.link(&in_y.out, &skip_y.in);
	net.link(&skip_y.out, &delay_y.in);

        net.link(&delay_u.dout, &bus.in1);
        net.link(&delay_y.dout, &bus.in2);
        net.link(&bus.out, &nnplant.x);

        net.link(&in_y.out, &skip_yt.in);
	net.link(&skip_yt.out, &delay_yt.in);
	net.link(&delay_yt.dout, &statan_y.signal);
	net.link(&skip_yt.sync, &switch_y.turn);

	if(eAlgoKind == NaTrainingAlgorithm)
	  {
	    net.link(&delay_yt.dout, &nnteacher.desout);
	    net.link(&nnplant.y, &nnteacher.nnout);
	  }

	net.link(&in_y.out, &switch_y.in2);
	net.link(&nnplant.y, &switch_y.in1);
	net.link(&switch_y.out, &nn_y.in);

        net.link(&nnplant.y, &errcomp.aux);
        net.link(&delay_yt.dout, &errcomp.main);
        net.link(&errcomp.cmp, &statan.signal);
    }catch(NaException ex){
        NaPrintLog("EXCEPTION at linkage phase: %s\n", NaExceptionMsg(ex));
    }
}


//---------------------------------------------------------------------------
// Run the network
NaPNEvent
NaNNRegrPlantLearn::run_net ()
{
    try{
        // Prepare petri net engine
        if(!net.prepare()){
            NaPrintLog("IMPORTANT: verification is failed!\n");
        }
        else{
            NaPNEvent       pnev;

            // Activities cycle
            do{
	      pnev = net.step_alive();

                idle_entry();

            }while(pneAlive == pnev);

            if(user_break())
                pnev = pneTerminate;

            net.terminate();

            return pnev;
        }
    }
    catch(NaException& ex){
        NaPrintLog("EXCEPTION at runtime phase: %s\n", NaExceptionMsg(ex));
    }
    return pneError;
}


//---------------------------------------------------------------------------

//////////////////
// Overloadable //
//////////////////

//---------------------------------------------------------------------------
// Check for user break
bool
NaNNRegrPlantLearn::user_break ()
{
#if defined(__MSDOS__) || defined(__WIN32__)
    if(kbhit()){
        int c = getch();
        if('x' == c || 'q' == c){
            return true;
        }
    }
#endif /* DOS & Win */
    return false;
}


//---------------------------------------------------------------------------
// Each cycle callback
void
NaNNRegrPlantLearn::idle_entry ()
{
  // Nothing to do
  if(delay_u.is_verbose())
    delay_u.print_status();
  if(delay_y.is_verbose())
    delay_y.print_status();
  if(delay_yt.is_verbose())
    delay_yt.print_status();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
