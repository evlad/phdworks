//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include "NaExcept.h"
#include "NaNNROE.h"


//---------------------------------------------------------------------------
// Create the object
NaNNRegrObjectEmulate::NaNNRegrObjectEmulate ()
: net("nncp2pn"),
  in_x("in_x"),
  in_y("in_y"),
  nn_y("nn_y"),
  nnobject("nnobject"),
  bus("bus"),
  errcomp("errcomp"),
  switcher("switcher"),
  trig_x("trig_x"),
  trig_y("trig_y"),
  delay("delay"),
  statan("statan")
{
    // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the object
NaNNRegrObjectEmulate::~NaNNRegrObjectEmulate ()
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
NaNNRegrObjectEmulate::link_net ()
{
    try{
        // Link the network
        net.link(&in_x.out, &trig_x.in);

        net.link(&trig_x.out, &bus.in1);
        net.link(&delay.dout, &bus.in2);
        net.link(&bus.out, &nnobject.x);

        net.link(&in_y.out, &delay.in);

        net.link(&in_y.out, &trig_y.in);

        net.link(&delay.sync, &trig_x.turn);
        net.link(&delay.sync, &trig_y.turn);

        net.link(&delay.sync, &switcher.turn);
        net.link(&nnobject.y, &switcher.in1);
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
NaNNRegrObjectEmulate::run_net ()
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
NaNNRegrObjectEmulate::user_break ()
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
NaNNRegrObjectEmulate::idle_entry ()
{
    // Nothing to do
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
 
