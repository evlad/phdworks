//-*-C++-*-
/* NaPNNNUn.h */
/* $Id: NaPNNNUn.h,v 1.1 2001-12-16 17:23:39 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNSkipH
#define NaPNSkipH

#include <NaNNUnit.h>
#include <NaDynAr.h>
#include <NaPetri.h>

//---------------------------------------------------------------------------
// Applied Petri net node: neural net unit with array of states.
// Has one input and one output of the neural network unit.

//---------------------------------------------------------------------------
class NaPNNNUnit : public NaPetriNode
{
public:

  // Create node for Petri network
  NaPNNNUnit (const char* szNodeName = "nnunit");


  ////////////////
  // Connectors //
  ////////////////

  // Input (mainstream)
  NaPetriCnInput	x;

  // Output (mainstream)
  NaPetriCnOutput	y;


  ///////////////////
  // Node specific //
  ///////////////////

  // Assign new neural net unit
  void		set_nn_unit (NaNNUnit* pNN);

  // Get neural net unit pointer
  NaNNUnit*	get_nn_unit ();

  // For compatibility reason
  void		set_transfer_func (NaNNUnit* pNN);

  // Request state storage
  void		need_nn_deck (bool bDeckRequest);

  // Put actual state of NN to the deck (first-in first-out)
  void		push_nn ();

  // Get the most ancient state of NN from the deck (first-in first-out)
  void		pop_nn (NaNNUnit& nnunit);


  ///////////////////////
  // Phases of network //
  ///////////////////////

  // 2. Link connectors inside the node
  virtual void	relate_connectors ();

  // 5. Verification to be sure all is OK (true)
  virtual bool	verify ();

  // 6. Initialize node activity and setup starter flag if needed
  virtual void	initialize (bool& starter);

  // 8. True action of the node (if activate returned true)
  virtual void	action ();

protected:/* data */

  // Neural net unit
  NaNNUnit		*nn;

  // 'true' to provide deck and 'false' to decline
  bool			need_deck;

  // First-in first-out structure
  NaDynAr<NaNNUnit>	deck;

};


//---------------------------------------------------------------------------
#endif
