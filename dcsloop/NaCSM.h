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
#include <NaPNFOut.h>
#include <NaPNBu21.h>
#include <NaPNDely.h>
#include <NaPNRand.h>
#include <NaPNDerv.h>
#include <NaPNCuSu.h>
#include <NaNDescr.h>


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

    ////////////////
    // Additional //
    ////////////////

    // Set initial observed state of a plant
    void		set_initial_state (const NaVector& v);

    // Set flag of using cummulative sum features
    void		set_cusum_flag (bool use_cusum);

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
    NaPNTransfer    plant;
    NaPNCheckPoint  chkpnt_y;
    NaPNCheckPoint  chkpnt_ny;
    NaPNSum         onsum;
    NaPNComparator  cmp_e;	// reference minus pure y produces e for MSE
    NaPNStatistics  statan_e;	// MSE computation
    NaPNStatistics  statan_r;
    NaPNBus2i1o     bus;        // (u,e)->NN former
    NaPNDelay       delay;      // (e(i),e(i-1),...e(i-n))->NN delayer-former
    NaPNDerivative  delta_e;    // (1-1/z)*e(k)
    NaPNCuSum       cusum;      // cumulative sum for change point detection
    NaPNFileOutput  cusum_out;  // output of cumulative sum

private:/* data */

    // Kind of controller
    NaControllerKind	eContrKind;

    // Length of series or 0 for data input
    int			nSeriesLen;

    // Initial state of a plant
    NaVector		vInitial;

    // Cummulative sum usage
    bool		bUseCuSum;

};


//---------------------------------------------------------------------------
#endif
