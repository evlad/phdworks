//---------------------------------------------------------------------------

#include "NaPNSum.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNSum::NaPNSum (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  main(this, "main"),
  aux(this, "aux"),
  sum(this, "sum")
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
NaPNSum::main_input_cn ()
{
    return &main;
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNSum::relate_connectors ()
{
    sum.data().new_dim(main.data().dim());
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNSum::verify ()
{
    return main.data().dim() == aux.data().dim()
        && main.data().dim() == sum.data().dim();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNSum::action ()
{
    unsigned    i;

    for(i = 0; i < sum.data().dim(); ++i){
        sum.data()[i] = main.data()[i] + aux.data()[i];
    }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
 