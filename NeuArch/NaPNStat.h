//-*-C++-*-
/* NaPNStat.h */
/* $Id: NaPNStat.h,v 1.4 2001-12-11 21:20:48 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNStatH
#define NaPNStatH

#include <NaPetri.h>


//---------------------------------------------------------------------------
// Applied Petri net node: compute statistics for the N-dimensional signal.
// Has the only input which can be N-dimensional.  Computes mean, StdDeversion
// and mean square error (MSE).

//---------------------------------------------------------------------------
class NaPNStatistics : public NaPetriNode
{
public:

    // Create node for Petri network
    NaPNStatistics (const char* szNodeName = "statistics");


    ////////////////
    // Connectors //
    ////////////////

    // Input (mainstream)
    NaPetriCnInput      signal;


    ///////////////////
    // Node specific //
    ///////////////////

    // Print to the log statistics
    void                print_stat (const char* szTitle = NULL);


    /////////////////////////
    // Computed statistics //
    /////////////////////////

    // Mean value: M(signal)
    NaVector            Mean;

    // Standard deviation value: d(signal) = sqrt(M(signal^2) - M(signal)^2)
    NaVector            StdDev;

    // Root mean square: M(signal^2)
    NaVector            RMS;

    // Minimum value of the series
    NaVector            Min;

    // Maximum value of the series
    NaVector            Max;



    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 4. Allocate resources for internal usage
    virtual void        allocate_resources ();

    // 5. Verification to be sure all is OK (true)
    virtual bool        verify ();

    // 6. Initialize node activity and setup starter flag if needed
    virtual void        initialize (bool& starter);

    // 8. True action of the node (if activate returned true)
    virtual void        action ();

private:

    /////////////////////////
    // Temporal statistics //
    /////////////////////////

    NaVector            Sum;
    NaVector            Sum2;

};


//---------------------------------------------------------------------------
#endif
