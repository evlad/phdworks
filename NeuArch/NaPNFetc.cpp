/* NaPNFetc.cpp */
static char rcsid[] = "$Id: NaPNFetc.cpp,v 1.4 2001-05-15 06:02:22 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNFetc.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNFetcher::NaPNFetcher (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  in(this, "in"),
  out(this, "out")
{
    piOutMap = NULL;	// Inputs in output vector
    nOutDim = -1;	// Output dimension
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Set output dimension and position of input
void
NaPNFetcher::set_output (unsigned iPos, int nDim)
{
  check_tunable();

  nOutDim = nDim;
  delete piOutMap;

  if(nOutDim < 0)
    piOutMap = NULL;
  else
    {
      unsigned	i;
      piOutMap = new unsigned[nOutDim];
      for(i = 0; i < nOutDim; ++i)
	piOutMap[i] = iPos + i;
    }
}


//---------------------------------------------------------------------------
// Set output dimension and positions of input (0,1...)
void
NaPNFetcher::set_output (int nDim, unsigned* piMap)
{
  check_tunable();

  nOutDim = nDim;
  delete piOutMap;

  if(nOutDim < 0)
    piOutMap = NULL;
  else if(NULL == piMap)
    throw(na_null_pointer);
  else
    {
      unsigned	i;
      piOutMap = new unsigned[nOutDim];
      for(i = 0; i < nOutDim; ++i)
	piOutMap[i] = piMap[i];
    }
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNFetcher::relate_connectors ()
{
    if(nOutDim >= 0){
        out.data().new_dim(nOutDim);
    }
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNFetcher::verify ()
{
  if(nOutDim < 0){
    NaPrintLog("VERIFY FAILED: output dimension is not set!\n");
    return false;
  }

  unsigned	i, iMaxPos = 0;
  for(i = 0; i < nOutDim; ++i){
    if(iMaxPos < piOutMap[i])
      iMaxPos = piOutMap[i];
  }

  if((unsigned)iMaxPos >= in.data().dim()){
    NaPrintLog("VERIFY FAILED: some output positions are out of input range!\n");
    return false;
  }

  return true;
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNFetcher::action ()
{
  unsigned	i;
  for(i = 0; i < nOutDim; ++i){
    out.data()[i] = in.data()[piOutMap[i]];
  }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
 
