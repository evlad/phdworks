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
    iInpPos = -1;       // Position of input vector in output
    nOutDim = -1;       // Output dimension
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Set output dimension and position of input
void
NaPNFetcher::set_output (int iPos, int nDim)
{
    check_tunable();

    iInpPos = iPos;
    nOutDim = nDim;
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
    if(iInpPos < 0){
        NaPrintLog("VERIFY FAILED: input position is not set!\n");
        return false;
    }
    return (unsigned)(nOutDim + iInpPos) <= in.data().dim();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNFetcher::action ()
{
    int i;
    for(i = 0; i < nOutDim; ++i){
        out.data()[i] = in.data()[i + iInpPos];
    }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
 