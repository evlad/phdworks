//-*-C++-*-
/* NaPNQIn.h */
/* $Id: NaPNQIn.h,v 1.1 2001-06-23 08:59:57 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNQInH
#define NaPNQInH

#include <NaPetri.h>


//---------------------------------------------------------------------------
// Applied Petri net node: external data reader.
// Has no input and the only output.  Reads data to queue value-by-value.

//---------------------------------------------------------------------------
class NaPNQueueInput : public NaPetriNode
{
public:

  // Create node
  NaPNQueueInput (const char* szNodeName = "queuein");

  // Destroy the node
  virtual ~NaPNQueueInput ();


  ////////////////
  // Connectors //
  ////////////////

  // Mainstream output
  NaPetriCnOutput	out;


  ///////////////////
  // Node specific //
  ///////////////////

  // Set dimension of input data
  virtual void		set_data_dim (unsigned n = 1);

  // Put data to the queue
  virtual void		put_data (const NaReal* pPortion);


  ///////////////////////
  // Phases of network //
  ///////////////////////

  // 2. Link connectors inside the node
  virtual void		relate_connectors ();

  // 6. Initialize node activity and setup starter flag if needed
  virtual void		initialize (bool& starter);

  // 7. Do one step of node activity and return true if succeeded
  virtual bool		activate ();

  // 8. True action of the node (if activate returned true)
  virtual void		action ();

protected:

  // Queue buffer
  NaVector		vQueue;

  // Data size portion
  unsigned		nDataSize;

};


//---------------------------------------------------------------------------
#endif
