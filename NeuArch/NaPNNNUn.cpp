/* NaPNNNUn.cpp */
static char rcsid[] = "$Id: NaPNNNUn.cpp,v 1.3 2001-12-23 14:40:59 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNNNUn.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNNNUnit::NaPNNNUnit (const char* szNodeName)
  : NaPetriNode(szNodeName), nn(NULL),
    need_deck(false), skip_deck(0), skip_rest(0),
    ////////////////
    // Connectors //
    ////////////////
    x(this, "x"),
    y(this, "y")
{
  // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Assign new neural net
void
NaPNNNUnit::set_nn_unit (NaNNUnit* pNN)
{
  check_tunable();

  if(NULL == pNN)
    throw(na_null_pointer);

  nn = pNN;
}


//---------------------------------------------------------------------------
// Get neural net unit pointer
NaNNUnit*
NaPNNNUnit::get_nn_unit ()
{
  return nn;
}


//---------------------------------------------------------------------------
// For compatibility reason
void
NaPNNNUnit::set_transfer_func (NaNNUnit* pNN)
{
  set_nn_unit(pNN);
}


//---------------------------------------------------------------------------
// Request state storage
void
NaPNNNUnit::need_nn_deck (bool bDeckRequest, unsigned nSkipFirst)
{
  need_deck = bDeckRequest;
  skip_deck = nSkipFirst;
}


//---------------------------------------------------------------------------
// Put actual state of NN to the deck (first-in first-out)
void
NaPNNNUnit::push_nn ()
{
  if(skip_rest > 0){
    --skip_rest;
  }else{
    deck.addh(*nn);
  }

  if(is_verbose())
    NaPrintLog("NaPNNNUnit::push_nn(%s.%s, %p) --> %u items stored\n",
	       net()->name(), name(), this, deck.count());
}


//---------------------------------------------------------------------------
// Get the most ancient state of NN from the deck (first-in first-out)
void
NaPNNNUnit::pop_nn (NaNNUnit& nnunit)
{
  nnunit = deck(0);
  deck.remove(0);

  if(is_verbose())
    NaPrintLog("NaPNNNUnit::pop_nn(%s.%s, %p) --> %u items stored left\n",
	       net()->name(), name(), this, deck.count());
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNNNUnit::relate_connectors ()
{
  if(NULL != nn){
    x.data().new_dim(nn->InputDim());
    y.data().new_dim(nn->OutputDim());
  }
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNNNUnit::verify ()
{
  if(NULL == nn){
    NaPrintLog("NN unit is not defined for node '%s'.\n", name());
    return false;
  }else{
    return nn->InputDim() == x.data().dim()
      && nn->OutputDim() == y.data().dim();
  }
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNNNUnit::initialize (bool& starter)
{
  nn->Reset();
  deck.clean();
  skip_rest = skip_deck;
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNNNUnit::action ()
{
  nn->Function(&x.data()[0], &y.data()[0]);

  if(need_deck)
    push_nn();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
