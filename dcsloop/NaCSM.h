//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaCSMH
#define NaCSMH

#include <NaPetri.h>
#include <NaPNSum.h>
#include <NaPNCmp.h>
#include <NaPNGen.h>
#include <NaPNTran.h>
#include <NaPNTime.h>
#include <NaPNStat.h>
#include <NaPNChPt.h>
#include <NaPNFIn.h>
#include <NaPNBu21.h>
#include <NaPNDely.h>
#include <NaPNRand.h>


//---------------------------------------------------------------------------
// Kind of controller
enum NaControllerKind
{
  NaLinearContr,
  NaNeuralContrDelayedE,
  NaNeuralContrER
};


//---------------------------------------------------------------------------
// Class for traditional control system modelling
class NaControlSystemModel
{
public:/* methods */

    // Create control system with stream of given length in input or with
    // with data files if len=0
    NaControlSystemModel (int len, NaControllerKind ckind);

    // Destroy the object
    virtual ~NaControlSystemModel ();


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
    NaPNFileInput   setpnt_inp;
    NaPNRandomGen   setpnt_gen;
    NaPNCheckPoint  chkpnt_r;
    NaPNComparator  cmp;
    NaPNCheckPoint  chkpnt_e;
    NaPNTransfer    controller;
    NaPNCheckPoint  chkpnt_u;
    NaPNFileInput   noise_inp;
    NaPNRandomGen   noise_gen;
    NaPNCheckPoint  chkpnt_n;
    NaPNTransfer    object;
    NaPNCheckPoint  chkpnt_y;
    NaPNCheckPoint  chkpnt_ny;
    NaPNSum         onsum;
    NaPNComparator  cmp_e;	// reference minus pure y produces e for MSE
    NaPNStatistics  statan_e;	// MSE computation
    NaPNStatistics  statan_r;
    NaPNBus2i1o     bus;        // (u,e)->NN former
    NaPNDelay       delay;      // (e(i),e(i-1),...e(i-n))->NN delayer-former

private:/* data */

    // Kind of controller
    NaControllerKind	eContrKind;

    // Length of series or 0 for data input
    int		nSeriesLen;

};


//---------------------------------------------------------------------------
#endif
