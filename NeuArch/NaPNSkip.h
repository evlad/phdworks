//-*-C++-*-
/* NaPNSkip.h */
/* $Id: NaPNSkip.h,v 1.1 2001-12-15 16:07:35 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNSkipH
#define NaPNSkipH

#include <NaPetri.h>

//---------------------------------------------------------------------------
// Applied Petri net node: skip some samples in input stream.
// Has one input and one output of the same dimension.  Simply skips n first
// values from the input stream.

//---------------------------------------------------------------------------
class NaPNSkip : public NaPetriNode
{
public:

  // Create node for Petri network
  NaPNSkip (const char* szNodeName = "skip");


  ////////////////
  // Connectors //
  ////////////////

  // Input (mainstream)
  NaPetriCnInput	in;

  // Output (mainstream)
  NaPetriCnOutput	out;


  ///////////////////
  // Node specific //
  ///////////////////

  // Set number of data portions to skip
  void		set_skip_number (unsigned n);


  ///////////////////////
  // Phases of network //
  ///////////////////////

  // 2. Link connectors inside the node
  virtual void	relate_connectors ();

  // 5. Verification to be sure all is OK (true)
  virtual bool	verify ();

  // 8. True action of the node (if activate returned true)
  virtual void	action ();

  // 9. Finish data processing by the node (if activate returned true)
  virtual void	post_action ();

private:

  // Number of samples to skip
  unsigned	nSkip;

};


//---------------------------------------------------------------------------
#endif
