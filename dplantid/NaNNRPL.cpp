/* NaNNRPL.cpp */
static char rcsid[] = "$Id: NaNNRPL.cpp,v 1.2 2001-05-08 16:12:15 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include <NaExcept.h>
#include "NaNNRPL.h"


//---------------------------------------------------------------------------
// Create the object
NaNNRegrPlantLearn::NaNNRegrPlantLearn (NaAlgorithmKind akind)
: net("nncp2pn"), eAlgoKind(akind),
  in_u("in_u"),
  in_y("in_y"),
  nn_y("nn_y"),
  nnplant("nnplant"),
  nnteacher("nnteacher"),
  bus("bus"),
  errcomp("errcomp"),
  switcher("switcher"),
  trig_y("trig_y"),
  delay_u("delay_u"),
  delay_y("delay_y"),
  statan("statan"),
  statan_y("statan_y"),
  and("and")
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
        net.link(&in_u.out, &delay_u.in);
        net.link(&in_y.out, &delay_y.in);

        net.link(&delay_u.dout, &bus.in1);
        net.link(&delay_y.dout, &bus.in2);
        net.link(&bus.out, &nnplant.x);

        net.link(&in_y.out, &statan_y.signal);
        net.link(&in_y.out, &trig_y.in);

	if(eAlgoKind == NaTrainingAlgorithm)
	  {
	    net.link(&trig_y.out, &nnteacher.desout);
	    net.link(&nnplant.y, &nnteacher.nnout);
	  }

        net.link(&delay_u.sync, &and.in1);
        net.link(&delay_y.sync, &and.in2);

	net.link(&and.out, &trig_y.turn);
        net.link(&and.out, &switcher.turn);

        net.link(&nnplant.y, &switcher.in1);
        net.link(&in_y.out, &switcher.in2);
        net.link(&switcher.out, &nn_y.in);

        net.link(&switcher.out, &errcomp.aux);
        net.link(&in_y.out, &errcomp.main);
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
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
