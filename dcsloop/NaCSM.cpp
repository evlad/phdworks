//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include <NaExcept.h>
#include "NaCSM.h"


//---------------------------------------------------------------------------
// Create control system with stream of given length in input or with
// with data files if len=0
NaControlSystemModel::NaControlSystemModel (int len, NaControllerKind ckind)
  : net("nncp0pn"), nSeriesLen(len), eContrKind(ckind),
  setpnt_inp("setpnt_inp"),
  setpnt_gen("setpnt_gen"),
  chkpnt_r("chkpnt_r"),
  bus("bus"),
  delay("delay"),
  cmp("cmp"),
  chkpnt_e("chkpnt_e"),
  controller("controller"),
  chkpnt_u("chkpnt_u"),
  noise_inp("noise_inp"),
  noise_gen("noise_gen"),
  chkpnt_n("chkpnt_n"),
  object("object"),
  chkpnt_y("chkpnt_y"),
  onsum("onsum"),
  chkpnt_ny("chkpnt_ny"),
  cmp_e("cmp_e"),
  statan_e("statan_e"),
  statan_r("statan_r")
{
    // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the object
NaControlSystemModel::~NaControlSystemModel ()
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
NaControlSystemModel::link_net ()
{
    try{
        // Link the network
        net.link_nodes(
                       (0==nSeriesLen)? &setpnt_inp: &setpnt_gen,
		       &chkpnt_r,
                       &cmp,
                       &chkpnt_e,
                       NULL);

	switch(eContrKind)
	  {
	  case NaLinearContr:
	    net.link(&chkpnt_e.out, &controller.x);
	    break;
	  case NaNeuralContrDelayedE:
	    net.link(&chkpnt_e.out, &delay.in);
	    net.link(&delay.dout, &controller.x);
	    break;
	  case NaNeuralContrER:
	    net.link(&chkpnt_r.out, &bus.in1);
	    net.link(&chkpnt_e.out, &bus.in2);
	    net.link(&bus.out, &controller.x);
	    break;
	  }

        net.link_nodes(
                       &controller,
		       &chkpnt_u,
                       &object,
		       &chkpnt_y,
		       &onsum,
                       &chkpnt_ny,
                       NULL);
        net.link_nodes(
                       (0==nSeriesLen)? &noise_inp: &noise_gen,
                       &chkpnt_n,
                       NULL);


        net.link(&chkpnt_ny.out, &cmp.aux);
        net.link(&chkpnt_n.out, &onsum.aux);

        net.link(&chkpnt_r.out, &cmp_e.main);
        net.link(&object.y, &cmp_e.aux);

        net.link(&cmp_e.cmp, &statan_e.signal);
        net.link(&chkpnt_r.out, &statan_r.signal);

    }catch(NaException ex){
        NaPrintLog("EXCEPTION at linkage phase: %s\n", NaExceptionMsg(ex));
    }
}


//---------------------------------------------------------------------------
// Run the network
NaPNEvent
NaControlSystemModel::run_net ()
{
    try{
        NaVector	rZero(1);
	rZero.init_zero();
	NaVector	rMain(1), rAux(1);
	rMain.init_value(1.);
	rAux.init_value(-1.);

        chkpnt_y.out.set_starter(rZero);
	onsum.set_gain(rMain, rAux);

	net.set_timing_node((0==nSeriesLen)? &setpnt_inp: &setpnt_gen);

        // Prepare petri net engine
        if(!net.prepare()){
            NaPrintLog("IMPORTANT: verification is failed!\n");
        }
        else{
            NaPNEvent       pnev;

#if defined(__MSDOS__) || defined(__WIN32__)
            printf("Press 'q' or 'x' for exit\n");
#endif /* DOS & Win */

            // Activities cycle
            do{
                pnev = net.step_alive();

                idle_entry();

		if(0 != nSeriesLen && setpnt_gen.activations() > nSeriesLen)
		    pnev = pneDead;

                if(user_break())
                    pnev = pneTerminate;

            }while(pneAlive == pnev);

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
NaControlSystemModel::user_break ()
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
NaControlSystemModel::idle_entry ()
{
    // Dummy
    printf("Sample %u\r", net.timer().CurrentIndex());
    fflush(stdout);
}


//---------------------------------------------------------------------------
#pragma package(smart_init)