/* PNPrint.cpp */
static char rcsid[] = "$Id: PNPrint.cpp,v 1.2 2001-05-15 06:02:23 vlad Exp $";
//---------------------------------------------------------------------------

#include <stdio.h>

#include "PNPrint.h"


//---------------------------------------------------------------------------
NaPNPrinter::NaPNRandomGen (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  in(this, "in")
{
    // nothing more
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNPrinter::action ()
{
    NaVector    &vect = rand.data();
    unsigned    i;

    printf("%s:");
    for(i = 0; i < vect.dim(); ++i){
        printf("\t%g", vect[i]);
    }
    printf("\n");
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
