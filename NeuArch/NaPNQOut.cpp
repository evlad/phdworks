/* NaPNQOut.cpp */
static char rcsid[] = "$Id: NaPNQOut.cpp,v 1.3 2001-07-02 20:00:41 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNQOut.h"


//---------------------------------------------------------------------------
// Create node
NaPNQueueOutput::NaPNQueueOutput (const char* szNodeName)
  : NaPetriNode(szNodeName), nQLimit(1),
    ////////////////
    // Connectors //
    ////////////////
    in(this, "in")
{
  // Nothing
}


//---------------------------------------------------------------------------
// Destroy the node
NaPNQueueOutput::~NaPNQueueOutput ()
{
  // Nothing
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Get dimension of output data
unsigned
NaPNQueueOutput::get_data_dim ()
{
  if(tunable())
    return 0;	/* unknown dimension */

  return in.data().dim();
}


//---------------------------------------------------------------------------
// Set maximum number of stored items
void
NaPNQueueOutput::set_queue_limit (unsigned n)
{
  if(n <= 0)
    throw(na_bad_value);

  nQLimit = n;
}


//---------------------------------------------------------------------------
// Get data from the queue
void
NaPNQueueOutput::get_data (NaReal* pPortion)
{
  unsigned	i;

  if(NULL != pPortion)
    {
      // Get data from the queue
      for(i = 0; i < get_data_dim(); ++i){
	pPortion[i] = vQueue(i);
      }
    }
  // else
  //   remove

  // Remove data portion
  vQueue.shift(- (int)get_data_dim());
  vQueue.new_dim(vQueue.dim() - get_data_dim());
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNQueueOutput::initialize (bool& starter)
{
  // Make empty queue
  vQueue.new_dim(0);
}


//---------------------------------------------------------------------------
// 7. Do one step of node activity and return true if succeeded
bool
NaPNQueueOutput::activate ()
{
  // Check the limit of queue length is not reached
  return NaPetriNode::activate()
    && (vQueue.dim() < get_data_dim() * nQLimit);
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNQueueOutput::action ()
{
  unsigned	i;

  vQueue.new_dim(vQueue.dim() + get_data_dim());

  for(i = 0; i < get_data_dim(); ++i){
    vQueue[vQueue.dim() + i - get_data_dim()] = in.data()[i];
  }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
