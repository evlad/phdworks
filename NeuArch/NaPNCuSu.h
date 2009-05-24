//-*-C++-*-
/* NaPNCuSu.h */
/* $Id: NaPNCuSu.h,v 1.2 2003-07-07 20:24:09 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNCuSuH
#define NaPNCuSuH

#include <NaPetri.h>


//---------------------------------------------------------------------------
// Node of CUSUM method implementation - change-point detection problem.
// Detection of standard deviation is performed.

//---------------------------------------------------------------------------
class NaPNCuSum : public NaPetriNode
{
public:

  // Create node for Petri network
  NaPNCuSum (const char* szNodeName = NULL);

  // Destroy the node
  virtual	~NaPNCuSum ();

  ////////////////
  // Connectors //
  ////////////////

  // Controlled signal (mainstream)
  NaPetriCnInput	x;

  // Detection of std.dev. disorder (mainstream) 0-no, 1-yes
  NaPetriCnOutput	d;

  // Imaging point
  NaPetriCnOutput	sum;


  ///////////////////
  // Node specific //
  ///////////////////

  // Setup parameters
  void		setup (NaReal sigma0, NaReal sigma1,
		       NaReal h_sol, NaReal k_const = 0.0);


  ///////////////////
  // Quick linkage //
  ///////////////////

  // Return mainstream input connector (the only input or NULL)
  virtual NaPetriConnector*	main_input_cn ();

  // Return mainstream output connector (the only output or NULL)
  virtual NaPetriConnector*	main_output_cn ();


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

protected:/* methods */

  // Gaussian distribution
  static NaReal	gaussian_distrib (NaReal sigma, NaReal Xt);

  // Imaging point computation S(t) on the basis of S(t-1)
  NaReal	imaging_point (NaReal Sprev, NaReal Xt);

protected:/* data */

  NaReal	fSigma[2];	// sigma0 and sigma1
  NaReal	fTopVal;	// solution level
  NaReal	fK;		// constant k
  NaReal	fS;		// imaging point

};


//---------------------------------------------------------------------------
#endif
