/* NaPNTimD.cpp */
static char rcsid[] = "$Id: NaPNTimD.cpp,v 1.2 2001-05-15 06:02:22 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNTimD.h"
#include "NaPNTime.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNTimeDepend::NaPNTimeDepend (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  time(this, "time")
{
    // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Get timer object (linked with 'time' connector)
NaTimer&
NaPNTimeDepend::timer () const
{
    NaPNTimer   *pPNTimer = (NaPNTimer*)time.host();
    return *pPNTimer;
}


//---------------------------------------------------------------------------

/////////////////////
// Timer functions //
/////////////////////

//---------------------------------------------------------------------------
// Set new sampling rate
void
NaPNTimeDepend::SetSamplingRate (NaReal sr)
{
    timer().SetSamplingRate(sr);
}


//---------------------------------------------------------------------------
// Get current sampling rate
NaReal
NaPNTimeDepend::GetSamplingRate () const
{
    return timer().GetSamplingRate();
}


//---------------------------------------------------------------------------
// Reset time/index counter to 0
void
NaPNTimeDepend::ResetTime ()
{
    timer().ResetTime();
}


//---------------------------------------------------------------------------
// Go to next time/index
void
NaPNTimeDepend::GoNextTime ()
{
    timer().GoNextTime();
}


//---------------------------------------------------------------------------
// Return current time
NaReal
NaPNTimeDepend::CurrentTime () const
{
    return time.data()(0);
}


//---------------------------------------------------------------------------
// Return current index
int
NaPNTimeDepend::CurrentIndex () const
{
    return (int)(CurrentTime() / GetSamplingRate());
}



//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNTimeDepend::verify ()
{
    if(strcmp(time.adjoint()->name(), "time")){
        NaPrintLog("Time dependent PN object '%s' must be linked "
                   "with NaPNTimer.\n", name());
        return false;
    }
    return 1 == time.data().dim();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
