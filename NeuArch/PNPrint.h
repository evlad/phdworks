//-*-C++-*-
/* PNPrint.h */
/* $Id: PNPrint.h,v 1.2 2001-05-15 06:02:23 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef PNPrintH
#define PNPrintH

#include <NaPetri.h>


//---------------------------------------------------------------------------
// Random number generator

class NaPNPrinter : public NaPetriNode
{
public:

    // Construct the printer (to stdout)
    NaPNPrinter (const char* szNodeName = "printer");


    ////////////////
    // Connectors //
    ////////////////

    // Random number
    NaPetriCnInput      in;


    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 8. True action of the node (if activate returned true)
    virtual void        action ();
    
};


//---------------------------------------------------------------------------
#endif
