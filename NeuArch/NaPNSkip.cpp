/* NaPNSkip.cpp */
static char rcsid[] = "$Id: NaPNSkip.cpp,v 1.1 2001-12-15 16:07:35 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNSkip.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNSkip::NaPNSkip (const char* szNodeName)
  : NaPetriNode(szNodeName), nSkip(0),
  ////////////////
  // Connectors //
  ////////////////
  in(this, "in"),
  out(this, "out")
{
  // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Set number of data portions to skip
void
NaPNSkip::set_skip_number (unsigned n)
{
  check_tunable();

  nSkip = n;
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNSkip::relate_connectors ()
{
  out.data().new_dim(in.data().dim());
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNSkip::verify ()
{
  return out.data().dim() == in.data().dim();
}



//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNSkip::action ()
{
  out.data() = in.data();
}


//---------------------------------------------------------------------------
// 9. Finish data processing by the node (if activate returned true)
void
NaPNSkip::post_action ()
{
  // Commit input anyway to get next data portion
  in.commit_data();

  if(activations() > nSkip)
    // Commit output only if given number of portions were skipped
    out.commit_data();
}
