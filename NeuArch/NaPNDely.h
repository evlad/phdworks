//-*-C++-*-
/* NaPNDely.h */
/* $Id: NaPNDely.h,v 1.4 2001-10-01 18:03:05 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNDelyH
#define NaPNDelyH

#include <NaPetri.h>
#include <NaUnit.h>


//---------------------------------------------------------------------------
// Applied Petri net node: delay unit.
// Repeats input few times on output.  Generates synchronization for
// depended nodes (see NaPNTrigger). 

//---------------------------------------------------------------------------
class NaPNDelay : public NaPetriNode
{
public:

    // Create node for Petri network
    NaPNDelay (const char* szNodeName = "delay");


    ////////////////
    // Connectors //
    ////////////////

    // Input (mainstream)
    NaPetriCnInput      in;

    // Output (mainstream)
    NaPetriCnOutput     dout;

    // Output for NaPNTrigger nodes synchronization
    NaPetriCnOutput     sync;


    ///////////////////
    // Quick linkage //
    ///////////////////

    // Return mainstream output connector (the only output or NULL)
    virtual NaPetriConnector*   main_output_cn ();


    ///////////////////
    // Node specific //
    ///////////////////

    // Set delay (0 - no delay, 1 - one delayed step, etc)
    void                set_delay (unsigned nSamples);

    // Set delay encoded in piMap[nDim]
    void                set_delay (unsigned nDim, unsigned* piMap);

    // Add delay
    void                add_delay (unsigned iShift);

    // Set value to substitute output in sleep time
    void                set_sleep_value (NaReal fValue);

    // Return true is passive sleep time is over and false otherwise
    bool                awake ();


    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 2. Link connectors inside the node
    virtual void        relate_connectors ();

    // 5. Verification to be sure all is OK (true)
    virtual bool        verify ();

    // 6. Initialize node activity and setup starter flag if needed
    virtual void        initialize (bool& starter);

    // 7. Do one step of node activity and return true if succeeded
    virtual bool        activate ();

    // 8. True action of the node (if activate returned true)
    virtual void        action ();

    // 9. Finish data processing by the node (if activate returned true)
    virtual void        post_action ();

protected:/* data */

    // Number of samples to delay
    unsigned            nDelay;

    // Awaken flag
    bool                bAwaken;

    // Sleep value flag
    bool                bSleepValue;

    // Sleep value
    NaReal              fSleepValue;

    // Buffer for data
    NaVector		vBuffer;

    // Position of delayed values
    unsigned		*piOutMap;

    // Output dimension (multiply by in.data().dim())
    int			nOutDim;

};


//---------------------------------------------------------------------------
#endif
 
