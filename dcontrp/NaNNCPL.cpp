/* NaNNCPL.cpp */
static char rcsid[] = "$Id: NaNNCPL.cpp,v 1.3 2001-06-18 19:22:53 vlad Exp $";
//---------------------------------------------------------------------------

#include <NaExcept.h>
#include "NaNNCPL.h"


//---------------------------------------------------------------------------
// Create the object
NaNNContrPreLearn::NaNNContrPreLearn (NaAlgorithmKind akind,
				      NaControllerKind ckind)
: net("nncp1pn"), eContrKind(ckind), eAlgoKind(akind),
  in_r("in_r"),
  bus("bus"),
  delay("delay"),
  delta_e("delta_e"),
  in_e("in_e"),
  in_u("in_u"),
  nn_u("nn_u"),
  nncontr("nncontr"),
  nnteacher("nnteacher"),
  errcomp("errcomp"),
  statan("statan"),
  statan_u("statan_u")
{
  // Nothing
}


//---------------------------------------------------------------------------
// Destroy the object
NaNNContrPreLearn::~NaNNContrPreLearn ()
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
NaNNContrPreLearn::link_net ()
{
    try{
        // Link the network

	switch(eContrKind)
	  {
	  case NaNeuralContrDelayedE:
	    net.link(&in_e.out, &delay.in);
	    net.link(&delay.dout, &nncontr.x);
	    break;
	  case NaNeuralContrER:
	    net.link(&in_r.out, &bus.in1);
	    net.link(&in_e.out, &bus.in2);
	    net.link(&bus.out, &nncontr.x);
	    break;
	  case NaNeuralContrEdE:
	    net.link(&in_e.out, &bus.in1);
	    net.link(&in_e.out, &delta_e.x);
	    net.link(&delta_e.dx, &bus.in2);
	    net.link(&bus.out, &nncontr.x);
	    break;
	  }
	if(eAlgoKind == NaTrainingAlgorithm)
	  {
	    net.link(&nncontr.y, &nnteacher.nnout);
	    net.link(&in_u.out, &nnteacher.desout);
	  }
        net.link(&nncontr.y, &errcomp.aux);
        net.link(&nncontr.y, &nn_u.in);
        net.link(&in_u.out, &errcomp.main);
        net.link(&errcomp.cmp, &statan.signal);

	if(NaNeuralContrER == eContrKind)
	  net.link(&in_r.out, &statan_u.signal);
    }catch(NaException ex){
        NaPrintLog("EXCEPTION at linkage phase: %s\n", NaExceptionMsg(ex));
    }
}


//---------------------------------------------------------------------------
// Run the network
NaPNEvent
NaNNContrPreLearn::run_net ()
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
NaNNContrPreLearn::user_break ()
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
NaNNContrPreLearn::idle_entry ()
{
    // Nothing to do
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
