//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaPNFetcH
#define NaPNFetcH

#include "NaPetri.h"


//---------------------------------------------------------------------------
// Applied Petri net node: make bus narrower
// Fetch [iPos..iPos+nDim] line to output bus.

//---------------------------------------------------------------------------
class NaPNFetcher : public NaPetriNode
{
public:

    // Create node for Petri network
    NaPNFetcher (const char* szNodeName = "fetcher");


    ////////////////
    // Connectors //
    ////////////////

    // Input (mainstream)
    NaPetriCnInput      in;

    // Output (mainstream)
    NaPetriCnOutput     out;


    ///////////////////
    // Node specific //
    ///////////////////

    // Set output dimension and position of input 
    virtual void        set_output (int iPos, int nDim = 1);


    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 2. Link connectors inside the node
    virtual void        relate_connectors ();

    // 5. Verification to be sure all is OK (true)
    virtual bool        verify ();

    // 8. True action of the node (if activate returned true)
    virtual void        action ();

protected:

    // Position of input vector in output
    int                 iInpPos;

    // Output dimension
    int                 nOutDim;

};


//---------------------------------------------------------------------------
#endif
 
