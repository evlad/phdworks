/* NaPNDely.cpp */
static char rcsid[] = "$Id: NaPNDely.cpp,v 1.4 2001-06-03 21:29:36 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNDely.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNDelay::NaPNDelay (const char* szNodeName)
: NaPetriNode(szNodeName),
  piOutMap(NULL),
  nOutDim(0),
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

    nOutDim = 1 + (nDelay = nSamples);
    piOutMap = new unsigned[nOutDim];
    unsigned	i;
    for(i = 0; i < nOutDim; ++i)
      piOutMap[i] = i;
    bAwaken = false;
}


//---------------------------------------------------------------------------
// Set delay encoded in piMap[nDim]
void
NaPNDelay::set_delay (unsigned nDim, unsigned* piMap)
{
  check_tunable();

  nOutDim = nDim;
  delete piOutMap;

  if(0 == nOutDim)
    throw(na_bad_value);
  else if(NULL == piMap)
    throw(na_null_pointer);

  piOutMap = new unsigned[nOutDim];
  nDelay = 0;
  unsigned	i;
  for(i = 0; i < nOutDim; ++i)
    {
      piOutMap[i] = piMap[i];
      if(piOutMap[i] > nDelay)
	nDelay = piOutMap[i];
    }
  ++nDelay;

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
    dout.data().new_dim(in.data().dim() * nOutDim);

    // Just for synchronization...
    sync.data().new_dim(1);
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNDelay::verify ()
{
    return 1 == sync.data().dim()
        && dout.data().dim() == in.data().dim() * nOutDim;
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNDelay::initialize (bool& starter)
{
    bAwaken = bSleepValue;
    dout.data().init_value(fSleepValue);
    vBuffer.new_dim(nDelay * in.data().dim());
}


//---------------------------------------------------------------------------
// 7. Do one step of node activity and return true if succeeded
bool
NaPNDelay::activate ()
{
    bAwaken = awake();

    if(bAwaken && is_verbose())
      {
	unsigned	i;
	NaPrintLog("node '%s' is awaken: activations=%d, delay=",
		   name(), activations());
	for(i = 0; i < nOutDim; ++i)
	  if(i + 1 == nOutDim)
	    NaPrintLog("%d\n", piOutMap[i]);
	  else
	    NaPrintLog("%d,", piOutMap[i]);
      }

    return !in.is_waiting() && !sync.is_waiting();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNDelay::action ()
{
    // Portion size
    unsigned	nSize = in.data().dim();

    // Make free space in buffer area
    vBuffer.shift(nSize);

    // Copy input data to buffer
    unsigned    i, j;
    for(i = 0; i < nSize; ++i)
      {
        vBuffer[i] = in.data()[i];
      }

    // Copy selected portions of stored data to output
    for(j = 0; j < nOutDim; ++j)
      for(i = 0; i < nSize; ++i)
	{
	  dout.data()[j * nSize + i] = vBuffer[piOutMap[j] * nSize + i];
	}

    // Sleep/awaken related nodes
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
