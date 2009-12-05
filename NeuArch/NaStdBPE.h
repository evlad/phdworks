//-*-C++-*-
/* NaStdBPE.h */
/* $Id$ */
//---------------------------------------------------------------------------
#ifndef NaStdBPEH
#define NaStdBPEH
//---------------------------------------------------------------------------

#include <NaVector.h>
#include <NaMatrix.h>
#include <NaNDescr.h>
#include <NaNNUnit.h>
#include <NaLogFil.h>

//---------------------------------------------------------------------------
// Learning coefficients
class NaStdBackPropParams : public NaLogging
{
public:

    NaStdBackPropParams ();

    NaReal      eta;        // Learning rate coefficient for hidden layers
    NaReal      eta_output; // Learning rate coefficient for output layer
    NaReal      alpha;      // Momentum (inertia coefficient)

    // Assignment of the object
    NaStdBackPropParams&    operator= (const NaStdBackPropParams& r);

    // Learning rate coefficient for the given layer
    virtual NaReal  LearningRate (unsigned iLayer) const;

    // Momentum (inertia coefficient) for the given layer
    virtual NaReal  Momentum (unsigned iLayer) const;

    virtual void    PrintLog () const;

};


//---------------------------------------------------------------------------
// Class for standard backpropagation learning environment
class NaStdBackProp : virtual public NaStdBackPropParams
{
public:/* methods */

    NaStdBackProp (NaNNUnit& rNN);
    virtual ~NaStdBackProp ();

    // Reset computed changes
    virtual void    ResetNN ();

    // Update network parameters on the basis of computed changes
    virtual void    UpdateNN ();

    // Delta rule for the last layer.
    // Ytarg is desired vector needs to be compared with Yout
    // of the output layer or error value already computed..
    // If bError==true then Ytarg means error ready to use without Yout.
    // If bError==false then Ytarg means Ydes to compare with Yout.
    virtual void    DeltaRule (const NaReal* Ytarg, bool bError = false);

    // Delta rule for the hidden layer
    // iLayer - index of target layer delta computation on the basis
    // of previous layer's delta and linked weights.
    // Usually iPrevLayer=iLayer+1.
    virtual void    DeltaRule (unsigned iLayer, unsigned iPrevLayer);

    // Part of delta rule for the hidden layer
    // Computes sum of products outcoming weights and target deltas
    // on given layer and for given input
    virtual NaReal  PartOfDeltaRule (unsigned iPrevLayer, unsigned iInput);

    // Compute delta weights based on common delta (see DeltaRule)
    virtual void    ApplyDelta (unsigned iLayer);

    // Compute delta of exact w[i,j,k]
    virtual NaReal  DeltaWeight (unsigned iLayer, unsigned iNeuron,
                                 unsigned iInput);

    // Compute delta of exact b[i,j]
    virtual NaReal  DeltaBias (unsigned iLayer, unsigned iNeuron);

    // Make slower learning rate for last layer
    // Learning rate coefficient for the given layer
    virtual NaReal  LearningRate (unsigned iLayer) const;

    // Return true if there is a need to prohibit bias change.
    virtual bool    DontTouchBias ();

public:/* data */

    // Linked neural network
    NaNNUnit    &nn;

    // Intermediate delta (t)
    NaVector    delta[NaMAX_HIDDEN+1];

    // Intermediate delta (t-1)
    NaVector    delta_prev[NaMAX_HIDDEN+1];

    // Accumulated changes: dw(t)
    NaMatrix    dWeight[NaMAX_HIDDEN+1];
    NaVector    dBias[NaMAX_HIDDEN+1];

    // Previous step of change: (w(t-1) - w(t-2))
    NaMatrix    psWeight[NaMAX_HIDDEN+1];
    NaVector    psBias[NaMAX_HIDDEN+1];

};

//---------------------------------------------------------------------------
#endif
