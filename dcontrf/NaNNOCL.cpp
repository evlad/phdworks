/* NaNNOCL.cpp */
static char rcsid[] = "$Id: NaNNOCL.cpp,v 1.1 2001-04-29 08:36:41 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include <NaExcept.h>
#include "NaNNOCL.h"


//---------------------------------------------------------------------------
// Create NN-C training control system with stream of given length
// in input or with with data files if len=0
NaNNOptimContrLearn::NaNNOptimContrLearn (int len, NaControllerKind ckind)
  : net("nncp3pn"), nSeriesLen(len), eContrKind(ckind),
    setpnt_inp("setpnt_inp"),
    setpnt_gen("setpnt_gen"),
    noise_inp("noise_inp"),
    noise_gen("noise_gen"),
    on_y("on_y"),
    nn_y("nn_y"),
    nn_u("nn_u"),
    nncontr("nncontr"),
    nnplant("nnplant"),
    plant("plant"),
    nnteacher("nnteacher"),
    errbackprop("errbackprop"),
    bus_p("bus_p"),
    bus_c("bus_c"),
    delay_c("delay_c"),
    sum_on("sum_on"),
    iderrcomp("iderrcomp"),
    iderrstat("iderrstat"),
    cerrcomp("cerrcomp"),
    cerrstat("cerrstat"),
    switch_y("switch_y"),
    trig_u("trig_u"),
    trig_e("trig_e"),
    delay("delay"),
    errfetch("errfetch")
{
  // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the object
NaNNOptimContrLearn::~NaNNOptimContrLearn ()
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
NaNNOptimContrLearn::link_net ()
{
  try{
    // Link the network

    switch(eContrKind)
      {
      case NaNeuralContrER:
	if(0 == nSeriesLen){
	  net.link(&setpnt_inp.out, &bus_c.in1);
	  net.link(&setpnt_inp.out, &cerrcomp.main);
	}else{
	  net.link(&setpnt_gen.y, &bus_c.in1);
	  net.link(&setpnt_gen.y, &cerrcomp.main);
	}
	net.link(&cerrcomp.cmp, &bus_c.in2);
	net.link(&bus_c.out, &nncontr.x);
	break;
      case NaNeuralContrDelayedE:
	if(0 == nSeriesLen)
	  net.link(&setpnt_inp.out, &cerrcomp.main);
	else
	  net.link(&setpnt_gen.y, &cerrcomp.main);
	net.link(&cerrcomp.cmp, &delay_c.in);
	net.link(&delay_c.dout, &nncontr.x);
	break;
      }

    net.link(&nncontr.y, &nn_u.in);
    net.link(&nn_u.out, &plant.x);
    net.link(&nn_u.out, &trig_u.in);

    net.link(&plant.y, &sum_on.main);
    if(0 == nSeriesLen)
      net.link(&noise_inp.out, &sum_on.aux);
    else
      net.link(&noise_gen.y, &sum_on.aux);
    net.link(&sum_on.sum, &on_y.in);

    net.link(&trig_u.out, &bus_p.in1);
    net.link(&delay.dout, &bus_p.in2);
    net.link(&bus_p.out, &nnplant.x);

    net.link(&on_y.out, &delay.in);

    net.link(&delay.sync, &trig_u.turn);
    net.link(&delay.sync, &trig_e.turn);
    net.link(&cerrcomp.cmp, &trig_e.in);
    net.link(&trig_e.out, &errbackprop.errout);

    net.link(&errbackprop.errinp, &errfetch.in);
    net.link(&errfetch.out, &nnteacher.errout);

    net.link(&delay.sync, &switch_y.turn);
    net.link(&nnplant.y, &switch_y.in1);
    net.link(&on_y.out, &switch_y.in2);
    net.link(&switch_y.out, &nn_y.in);

    net.link(&on_y.out, &iderrcomp.main);
    net.link(&switch_y.out, &iderrcomp.aux);
    net.link(&iderrcomp.cmp, &iderrstat.signal);

    net.link(&on_y.out, &cerrcomp.aux);
    net.link(&cerrcomp.cmp, &cerrstat.signal);

  }catch(NaException ex){
    NaPrintLog("EXCEPTION at linkage phase: %s\n", NaExceptionMsg(ex));
  }
}


//---------------------------------------------------------------------------
// Run the network
NaPNEvent
NaNNOptimContrLearn::run_net ()
{
  try{ 
    NaVector	rZero(1);
    rZero.init_zero();
    NaVector	rMain(1), rAux(1);
    rMain.init_value(1.);
    rAux.init_value(-1.);

    on_y.out.set_starter(rZero);
    sum_on.set_gain(rMain, rAux);

    net.set_timing_node((0==nSeriesLen)? &setpnt_inp: &setpnt_gen);

   // Prepare petri net engine
    if(!net.prepare(true)){
      NaPrintLog("IMPORTANT: verification is failed!\n");
    }
    else{
      NaPNEvent       pnev;

      // Activities cycle
      do{
	pnev = net.step_alive();

	idle_entry();

      }while(pneAlive == pnev);

      if(0 != nSeriesLen && setpnt_gen.activations() > nSeriesLen)
	pnev = pneDead;

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
NaNNOptimContrLearn::user_break ()
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
NaNNOptimContrLearn::idle_entry ()
{
  // Nothing to do
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
