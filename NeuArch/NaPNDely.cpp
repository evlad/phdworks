/* NaPNDely.cpp */
static char rcsid[] = "$Id: NaPNDely.cpp,v 1.3 2001-05-15 06:02:22 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNDely.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNDelay::NaPNDelay (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  in(this, "in"),
  dout(this, "dout"),
  sync(this, "sync")
{
    // No delay by default
    nDelay = 0;
    // Sleepy by default
    bAwaken = false;
    bSleepValue = false;
    fSleepValue = 0.0;
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Set delay (0 - no delay, 1 - one delayed step, etc)
void
NaPNDelay::set_delay (unsigned nSamples)
{
    check_tunable();

    nDelay = nSamples;
    bAwaken = false;
}


//---------------------------------------------------------------------------
// Set value to substitute output in sleep time
void
NaPNDelay::set_sleep_value (NaReal fValue)
{
    bSleepValue = true; // don't sleep for this case
    fSleepValue = fValue;
}


//---------------------------------------------------------------------------
// Return true is passive sleep time is over and false otherwise
bool
NaPNDelay::awake ()
{
    return activations() >= nDelay || bSleepValue;
}


//---------------------------------------------------------------------------

///////////////////
// Quick linkage //
///////////////////

//---------------------------------------------------------------------------
// Return mainstream output connector (the only output or NULL)
NaPetriConnector*
NaPNDelay::main_output_cn ()
{
    return &dout;
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNDelay::relate_connectors ()
{
    // Get nDelay + 1 times input vector
    dout.data().new_dim(in.data().dim() * (1 + nDelay));

    // Just for synchronization...
    sync.data().new_dim(1);
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNDelay::verify ()
{
    return 1 == sync.data().dim()
        && dout.data().dim() == in.data().dim() * (1 + nDelay);
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNDelay::initialize (bool& starter)
{
    bAwaken = bSleepValue;
    dout.data().init_value(fSleepValue);
}


//---------------------------------------------------------------------------
// 7. Do one step of node activity and return true if succeeded
bool
NaPNDelay::activate ()
{
    bAwaken = awake();

    if(bAwaken && is_verbose()){
        NaPrintLog("node '%s' is awaken: activations=%d, delay=%d\n",
                   name(), activations(), (int)nDelay);
    }

    return !in.is_waiting() && !sync.is_waiting();
    //    return !bAwaken && !in.is_waiting() && !sync.is_waiting()
    //        || bAwaken && NaPetriNode::activate();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNDelay::action ()
{
    dout.data().shift(in.data().dim());

    unsigned    i;
    for(i = 0; i < in.data().dim(); ++i){
        dout.data()[i] = in.data()[i];
    }

    if(bAwaken){
        sync.data()[0] = 1.0;   // Let linked nodes deliver data
    }else{
        sync.data()[0] = -1.0;  // Force to be passive linked nodes
    }
}


//---------------------------------------------------------------------------
// 9. Finish data processing by the node (if activate returned true)
void
NaPNDelay::post_action ()
{
    if(bAwaken){
        // Output data are ready, so deliver them
        dout.commit_data();
    }

    // Welcome for new data
    in.commit_data();

    // Manage linked nodes
    sync.commit_data();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
