/* NaPNCuSu.cpp */
static char rcsid[] = "$Id: NaPNCuSu.cpp,v 1.2 2003-07-07 20:23:35 vlad Exp $";
//---------------------------------------------------------------------------

#include <math.h>

#include "NaPNCuSu.h"


//---------------------------------------------------------------------------
// Setup parameters
void
NaPNCuSum::setup (NaReal sigma0, NaReal sigma1,
		  NaReal h_sol, NaReal k_const)
{
  fSigma[0] = sigma0;
  fSigma[1] = sigma1;
  fK = k_const;
  fTopVal = h_sol;
  fS = 0.0;
}


//---------------------------------------------------------------------------
// Gaussian distribution
NaReal
NaPNCuSum::gaussian_distrib (NaReal sigma, NaReal Xt)
{
  return exp(-Xt * Xt / 2 * sigma * sigma) / (sigma * sqrt(2 * M_PI));
}


//---------------------------------------------------------------------------
// Imaging point S(t) computation on the basis of S(t-1)
NaReal
NaPNCuSum::imaging_point (NaReal Sprev, NaReal Xt)
{
  NaReal	w0 = gaussian_distrib(fSigma[0], Xt);
  NaReal	w1 = gaussian_distrib(fSigma[1], Xt);
  NaReal	zt = log(w1 / w0);

  /*NaPrintLog("%g\t%g\t%g\t%g\t%g\n",
    Sprev, Sprev + zt - fK, w0, w1, zt);*/

  //return Sprev + zt - fK;
  NaReal	sq1 = fSigma[1] * fSigma[1];
  NaReal	sq0 = fSigma[0] * fSigma[0];

  //NaPrintLog("%g\t%g\n", zt, (-0.5*(1/sq1-1/sq0)*Xt*Xt - 0.5*log(sq1/sq0)));

  return Sprev + (-0.5*(1/sq1-1/sq0)*Xt*Xt - 0.5*log(sq1/sq0)) - fK;
}


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNCuSum::NaPNCuSum (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  x(this, "x"),
  d(this, "d"),
  sum(this, "sum")
{
  // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the node
NaPNCuSum::~NaPNCuSum ()
{
  // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Quick linkage //
///////////////////

//---------------------------------------------------------------------------
// Return mainstream input connector (the only input or NULL)
NaPetriConnector*
NaPNCuSum::main_input_cn ()
{
  return &x;
}


//---------------------------------------------------------------------------
// Return mainstream output connector (the only output or NULL)
NaPetriConnector*
NaPNCuSum::main_output_cn ()
{
  return &d;
}

//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNCuSum::relate_connectors ()
{
  d.data().new_dim(1);
  sum.data().new_dim(1);
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNCuSum::verify ()
{
  return 1 == x.data().dim()
    && 1 == d.data().dim()
    && 1 == sum.data().dim();
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNCuSum::initialize (bool& starter)
{
  fS = 0.0;
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNCuSum::action ()
{
  fS = imaging_point(fS, x.data()[0]);
  if(fS < 0.0)
    fS = 0.0;

  sum.data()[0]  = fS;

  // compute detection signal here
  if(fS > fTopVal)
    {
      d.data()[0] = 1;
      /* reset sum to initial one */
      fS = 0.0;
    }
  else
    d.data()[0] = 0;
}
