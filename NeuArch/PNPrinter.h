//-*-C++-*-
/* PNPrinter.h */
/* $Id: PNPrinter.h,v 1.2 2001-05-15 06:02:24 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef PNPrinterH
#define PNPrinterH

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
