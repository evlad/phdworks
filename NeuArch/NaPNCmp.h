//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaPNCmpH
#define NaPNCmpH

#include "NaPetri.h"


//---------------------------------------------------------------------------
// Applied Petri net node: comparator.
// Has two inputs: main and substractable, and one output - compared value
// inputs.

//---------------------------------------------------------------------------
class NaPNComparator : public NaPetriNode
{
public:

    // Create the comparator node
    NaPNComparator (const char* szNodeName = "comparator");

    ///////////////////
    // Quick linkage //
    ///////////////////

    // Return mainstream input connector (the only input or NULL)
    virtual NaPetriConnector*   main_input_cn ();


    ////////////////
    // Connectors //
    ////////////////

    // Dimensions of main and aux inputs must coinside

    // Mainstream input
    NaPetriCnInput      main;

    // Substractable input
    NaPetriCnInput      aux;

    // Dimension of output is equal to dimension of main input 

    // Mainstream output
    NaPetriCnOutput     cmp;


    ///////////////////
    // Node specific //
    ///////////////////

    // Set starter hint if needed (true by default)
    virtual void        set_starter (bool starter = true);


    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 2. Link connectors inside the node
    virtual void        relate_connectors ();

    // 5. Verification to be sure all is OK (true)
    virtual bool        verify ();

    // 6. Initialize node activity and setup starter flag if needed
    virtual void        initialize (bool& starter);

    // 8. True action of the node (if activate returned true)
    virtual void        action ();

protected:/* data */

    // Is the node a starter or not? 
    bool                bStarter;
};


//---------------------------------------------------------------------------
#endif
 
