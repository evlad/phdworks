//---------------------------------------------------------------------------

#include "NaExcept.h"
#include "NaPNRand.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNRandomGen::NaPNRandomGen (const char* szNodeName)
: NaPNGenerator(szNodeName),
  pRandAr(NULL)
  ////////////////
  // Connectors //
  ////////////////
  /* inherited */
{
    // Register itself as a generator unit
    set_generator_func(this);
}


//---------------------------------------------------------------------------
// Destroy node
NaPNRandomGen::~NaPNRandomGen ()
{
    delete[] pRandAr;
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Setup random generation with normal (Gauss) distribution
// with given output dimension
void
NaPNRandomGen::set_gauss_distrib (unsigned nDim,
                                  const NaReal* fMean, const NaReal* fStdDev)
{
    if(0 == nDim || NULL == fMean || NULL == fStdDev)
        throw(na_null_pointer);

    // Destroy previous RandomSequence objects
    delete[] pRandAr;
    pRandAr = NULL;

    // Change input-output dimension of the unit
    Assign(1, nDim, 0);

    // Setup distribution parameters
    pRandAr = new NaRandomSequence[nDim];

    // Setup distribution parameters
    unsigned    i;
    for(i = 0; i < nDim; ++i){
        pRandAr[i].SetDistribution(rdGaussNormal);
        pRandAr[i].SetGaussianParams(fMean[i], fStdDev[i]);
    }
}


//---------------------------------------------------------------------------
// Setup random generation with uniform distribution
// with given output dimension
void
NaPNRandomGen::set_uniform_distrib (unsigned nDim,
                                    const NaReal* fMin, const NaReal* fMax)
{
    if(0 == nDim || NULL == fMin || NULL == fMax)
        throw(na_null_pointer);

    // Destroy previous RandomSequence objects
    delete[] pRandAr;
    pRandAr = NULL;

    // Change input-output dimension of the unit
    Assign(1, nDim, 0);

    // Setup distribution parameters
    pRandAr = new NaRandomSequence[nDim];

    // Setup distribution parameters
    unsigned    i;
    for(i = 0; i < nDim; ++i){
        pRandAr[i].SetDistribution(rdUniform);
        pRandAr[i].SetUniformParams(fMin[i], fMax[i]);
    }
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

/* inherited */

//---------------------------------------------------------------------------

///////////////////////////
// Inherited from NaUnit //
///////////////////////////

//---------------------------------------------------------------------------
// Reset operations, that must be done before new modelling
// will start
void
NaPNRandomGen::Reset ()
{
    if(NULL != pRandAr){
        unsigned    i;
        for(i = 0; i < OutputDim(); ++i){
            pRandAr[i].Reset();
        }
    }
}


//---------------------------------------------------------------------------
// Compute pseudo-random output that depends on described
// random sequence law.  Input x does not matter.
void
NaPNRandomGen::Function (NaReal* x, NaReal* y)
{
    if(NULL != pRandAr){
        unsigned    i;
        for(i = 0; i < OutputDim(); ++i){
            pRandAr[i].Function(x, y + i);
        }
    }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
