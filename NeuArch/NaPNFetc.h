//-*-C++-*-
/* NaPNFetc.h */
/* $Id: NaPNFetc.h,v 1.4 2001-05-15 06:02:22 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNFetcH
#define NaPNFetcH

#include <NaPetri.h>


//---------------------------------------------------------------------------
// Applied Petri net node: make bus narrower
// Fetch [iPos..iPos+nDim] or [piMap(i)] lines to output bus.

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
    virtual void        set_output (unsigned iPos, int nDim = 1);

    // Set output dimension and positions of input (0,1...)
    virtual void        set_output (int nDim, unsigned* piMap);


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
    unsigned	*piOutMap;

    // Output dimension
    int		nOutDim;

};


//---------------------------------------------------------------------------
#endif
 
