//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaPNRandH
#define NaPNRandH

#include "NaPetri.h"
#include "NaRandom.h"
#include "NaPNGen.h"


//---------------------------------------------------------------------------
// Applied Petri net node: generator unit.
// Has no inputs and the only output

//---------------------------------------------------------------------------
class NaPNRandomGen : public NaPNGenerator, public NaUnit  
{
public:

    // Create node for Petri network
    NaPNRandomGen (const char* szNodeName = "randomgen");

    // Destroy node
    virtual ~NaPNRandomGen ();

    ////////////////
    // Connectors //
    ////////////////

    /* inherited */

    ///////////////////
    // Node specific //
    ///////////////////

    // Setup random generation with normal (Gauss) distribution
    // with given output dimension
    virtual void        set_gauss_distrib (unsigned nDim,
                                           const NaReal* fMean,
                                           const NaReal* fStdDev);

    // Setup random generation with uniform distribution
    // with given output dimension
    virtual void        set_uniform_distrib (unsigned nDim,
                                             const NaReal* fMin,
                                             const NaReal* fMax);


    ///////////////////////
    // Phases of network //
    ///////////////////////

    /* inherited */

    ///////////////////////////
    // Inherited from NaUnit //
    ///////////////////////////

    // Reset operations, that must be done before new modelling
    // will start
    virtual void    Reset ();

    // Compute pseudo-random output that depends on described
    // random sequence law.  Input x does not matter.
    virtual void    Function (NaReal* x, NaReal* y);

protected:/* data */

    // Array of RandomSequence units
    NaRandomSequence    *pRandAr;

};


//---------------------------------------------------------------------------
#endif
