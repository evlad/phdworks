/* NaNNOCL.cpp */
static char rcsid[] = "$Id: NaNNOCL.cpp,v 2.3 2002-01-15 12:41:48 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdio.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <conio.h>
#endif /* DOS & Win */

#include <NaExcept.h>
#include "NaNNOCL.h"


//---------------------------------------------------------------------------
// Create NN-C training control system with stream of given length
// in input or with data files if len=0
NaNNOptimContrLearn::NaNNOptimContrLearn (int len, NaControllerKind ckind,
					  const char* szNetName)
  : net(szNetName), nSeriesLen(len), eContrKind(ckind),
    setpnt_inp("setpnt_inp"),
    setpnt_gen("setpnt_gen"),
    setpnt_out("setpnt_out"),
    noise_inp("noise_inp"),
    noise_gen("noise_gen"),
    noise_out("noise_out"),
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
    delta_e("delta_e"),
    sum_on("sum_on"),
    iderrcomp("iderrcomp"),
    iderrstat("iderrstat"),
    cerrcomp("cerrcomp"),
    cerrstat("cerrstat"),
    skip_e("skip_e"),
    skip_u("skip_u"),
    skip_y("skip_y"),
    skip_ny("skip_ny"),
    fill_nn_y("fill_nn_y"),
    delay_u("delay_u"),
    delay_y("delay_y"),
    errfetch("errfetch"),
    cerr_fout("cerr_fout"),
    iderr_fout("iderr_fout"),
    cerr_qout("cerr_qout"),
    iderr_qout("iderr_qout"),
    c_in("c_in"),
    p_in("p_in")
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
	  net.link(&setpnt_gen.y, &setpnt_out.in);
	  net.link(&setpnt_gen.y, &cerrcomp.main);
	}
	net.link(&cerrcomp.cmp, &bus_c.in2);
	net.link(&bus_c.out, &nncontr.x);
	break;
      case NaNeuralContrDelayedE:
	if(0 == nSeriesLen){
	  net.link(&setpnt_inp.out, &cerrcomp.main);
	}
	else{
	  net.link(&setpnt_gen.y, &setpnt_out.in);
	  net.link(&setpnt_gen.y, &cerrcomp.main);
	}
	net.link(&cerrcomp.cmp, &delay_c.in);
	net.link(&delay_c.dout, &nncontr.x);
	break;
      case NaNeuralContrEdE:
	if(0 == nSeriesLen){
	  net.link(&setpnt_inp.out, &cerrcomp.main);
	}
	else{
	  net.link(&setpnt_gen.y, &setpnt_out.in);
	  net.link(&setpnt_gen.y, &cerrcomp.main);
	}
	net.link(&cerrcomp.cmp, &bus_c.in1);
	net.link(&cerrcomp.cmp, &delta_e.x);
	net.link(&delta_e.dx, &bus_c.in2);
	net.link(&bus_c.out, &nncontr.x);
	break;
      }

    net.link(&bus_c.out, &c_in.in);

    net.link(&nncontr.y, &nn_u.in);
    net.link(&nn_u.out, &plant.x);

    net.link(&plant.y, &sum_on.main);
    if(0 == nSeriesLen)
      net.link(&noise_inp.out, &sum_on.aux);
    else{
      net.link(&noise_gen.y, &noise_out.in);
      net.link(&noise_gen.y, &sum_on.aux);
    }
    net.link(&sum_on.sum, &on_y.in);

    net.link(&on_y.out, &skip_y.in);
    net.link(&nn_u.out, &skip_u.in);

    net.link(&skip_y.out, &delay_y.in);
    net.link(&skip_u.out, &delay_u.in);

    net.link(&delay_u.dout, &bus_p.in1);
    net.link(&delay_y.dout, &bus_p.in2);
    net.link(&bus_p.out, &nnplant.x);

    net.link(&bus_p.out, &p_in.in);

    net.link(&cerrcomp.cmp, &skip_e.in);
    net.link(&skip_e.out, &errbackprop.errout);

    net.link(&errbackprop.errinp, &errfetch.in);
    net.link(&errfetch.out, &nnteacher.errout);

    net.link(&on_y.out, &skip_ny.in);
    net.link(&skip_ny.out, &iderrcomp.main);
    net.link(&nnplant.y, &iderrcomp.aux);
    net.link(&iderrcomp.cmp, &iderrstat.signal);

    net.link(&nnplant.y, &fill_nn_y.in);
    net.link(&fill_nn_y.out, &nn_y.in);

    net.link(&on_y.out, &cerrcomp.aux);
    net.link(&cerrcomp.cmp, &cerrstat.signal);

    if(0 == nSeriesLen){
      net.link(&cerrstat.stat, &cerr_qout.in);
      net.link(&iderrstat.stat, &iderr_qout.in);
    }
    else{
      net.link(&cerrstat.stat, &cerr_fout.in);
      net.link(&iderrstat.stat, &iderr_fout.in);
    }

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

    cerrcomp.cmp.set_starter(rZero);
    sum_on.set_gain(rMain, rAux);

    net.set_timing_node((0==nSeriesLen)
			? (NaPetriNode*)&setpnt_inp
			: (NaPetriNode*)&setpnt_gen);

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

	if(pneAlive == pnev)
	  {
	    if(0 != nSeriesLen && setpnt_gen.activations() > nSeriesLen)
	      pnev = pneDead;
	    else if(user_break())
	      pnev = pneTerminate;
	  }

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
