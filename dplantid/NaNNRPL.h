// -*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaNNRPLH
#define NaNNRPLH

#include <NaPetri.h>
#include <NaPNSum.h>
#include <NaPNCmp.h>
#include <NaPNFIn.h>
#include <NaPNFOut.h>
#include <NaPNTran.h>
#include <NaPNStat.h>
#include <NaPNTchr.h>
#include <NaPNBu21.h>
#include <NaPNSwit.h>
#include <NaPNTrig.h>
#include <NaPNDely.h>
#include <NaPNLAnd.h>
#include <NaPNFetc.h>


//---------------------------------------------------------------------------
// Class for regression NN plant model learning.  Learning to predict one
// sample of plant output on the basis of few previous outputs and control
// sample.
class NaNNRegrPlantLearn
{
public:/* methods */

    // Create the object
    NaNNRegrPlantLearn (NaAlgorithmKind akind,
			const char* szNetName = "nncp2pn");

    // Destroy the object
    virtual ~NaNNRegrPlantLearn ();

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
    NaPNFileInput   in_y;       // target plant output
    NaPNFileInput   in_u;       // preset control force
    NaPNFileOutput  nn_y;       // NN plant output
    NaPNTransfer    nnplant;    // NN plant
    NaPNTeacher     nnteacher;  // NN teacher
    NaPNBus2i1o     bus;        // ((x,y),e)->NN former
    NaPNComparator  errcomp;    // error computer
    NaPNStatistics  statan;     // error estimator
    NaPNStatistics  statan_y;   // target plant output analyzer
    NaPNSwitcher    switcher;   // (nno,y)->(y_nn)
    NaPNTrigger     trig_y;     // pre-teacher y delayer
    NaPNDelay       delay_y;    // y -> y(-1), y(-2), ...
    NaPNDelay       delay_u;    // u -> u(-1), u(-2), ...
    NaPNLogicalAND  land;       // activate just after delay units are ready

private:/* data */

    // Kind of an algorithm
    NaAlgorithmKind	eAlgoKind;

};


//---------------------------------------------------------------------------
#endif
