//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaNNCPLH
#define NaNNCPLH

#include <NaPetri.h>
#include <NaPNSum.h>
#include <NaPNCmp.h>
#include <NaPNFIn.h>
#include <NaPNFOut.h>
#include <NaPNTran.h>
#include <NaPNStat.h>
#include <NaPNTchr.h>
#include <NaPNBu21.h>
#include <NaPNDely.h>


//---------------------------------------------------------------------------
// Class for simple NN controller learning.  Pre-learning to copy behaviour
// from some another controller.
class NaNNContrPreLearn
{
public:/* methods */

    // Create the object
    NaNNContrPreLearn (NaAlgorithmKind akind, NaControllerKind ckind);

    // Destroy the object
    virtual ~NaNNContrPreLearn ();

    ////////////////////
    // Network phases //
    ////////////////////

    // Link the network (tune the net before)
    virtual void        link_net ();

    // Run the network
    virtual NaPNEvent   run_net ();


    //////////////////
    // Overloadable //
    //////////////////

    // Check for user break
    virtual bool        user_break ();

    // Each cycle callback
    virtual void        idle_entry ();

public:/* data */

    // Main Petri network module
    NaPetriNet      net;

    // Functional Petri network nodes
    NaPNFileInput   in_r;       // set point
    NaPNBus2i1o     bus;        // (u,e)->NN former
    NaPNDelay       delay;      // (e(i),e(i-1),...e(i-n))->NN delayer-former
    NaPNFileInput   in_e;       // control error
    NaPNFileInput   in_u;       // target control force
    NaPNFileOutput  nn_u;       // NN output control force
    NaPNTransfer    nncontr;    // NN controller
    NaPNTeacher     nnteacher;  // NN teacher
    NaPNComparator  errcomp;    // error computer
    NaPNStatistics  statan;     // error estimator
    NaPNStatistics  statan_u;   // target controller output analyzer

private:/* data */

    // Kind of controller
    NaControllerKind	eContrKind;

    // Kind of an algorithm
    NaAlgorithmKind	eAlgoKind;

};


//---------------------------------------------------------------------------
#endif
