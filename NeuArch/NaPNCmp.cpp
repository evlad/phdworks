/* NaPNCmp.cpp */
static char rcsid[] = "$Id: NaPNCmp.cpp,v 1.3 2001-05-15 06:02:22 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNCmp.h"


//---------------------------------------------------------------------------
// Create the comparator node
NaPNComparator::NaPNComparator (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  main(this, "main"),
  aux(this, "aux"),
  cmp(this, "cmp")
{
  // dummy
}


//---------------------------------------------------------------------------

///////////////////
// Quick linkage //
///////////////////

//---------------------------------------------------------------------------
// Return mainstream input connector (the only input or NULL)
NaPetriConnector*
NaPNComparator::main_input_cn ()
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
NaPNComparator::relate_connectors ()
{
    cmp.data().new_dim(main.data().dim());
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNComparator::verify ()
{
    return main.data().dim() == aux.data().dim()
        && main.data().dim() == cmp.data().dim();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNComparator::action ()
{
    unsigned    i;

    // Both main and aux inputs are avaiable
    for(i = 0; i < cmp.data().dim(); ++i){
        cmp.data()[i] = main.data()[i] - aux.data()[i];
    }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
