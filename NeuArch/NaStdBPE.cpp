/* NaStdBPE.cpp */
static char rcsid[] = "$Id: NaStdBPE.cpp,v 1.5 2001-12-23 14:27:16 vlad Exp $";
//---------------------------------------------------------------------------
#include "NaLogFil.h"
#include "NaStdBPE.h"

//#define StdBPE_DEBUG
//#define PrintUpdateNN

//---------------------------------------------------------------------------
NaStdBackPropParams::NaStdBackPropParams ()
: eta(0.05), eta_output(0.001), alpha(0.0)
{
    // Dummy
}

//---------------------------------------------------------------------------
// Assignment of the object
NaStdBackPropParams&
NaStdBackPropParams::operator= (const NaStdBackPropParams& r)
{
    eta = r.eta;
    eta_output = r.eta_output;
    alpha = r.alpha;
    return *this;
}

//---------------------------------------------------------------------------
// Learning rate coefficient for the given layer
NaReal
NaStdBackPropParams::LearningRate (unsigned iLayer) const
{
    return eta;
}

//---------------------------------------------------------------------------
// Momentum (inertia coefficient) for the given layer
NaReal
NaStdBackPropParams::Momentum (unsigned iLayer) const
{
    return alpha;
}

//---------------------------------------------------------------------------
void
NaStdBackPropParams::PrintLog () const
{
    NaPrintLog("StdBackProp parameters: learning rate %g,  momentum %g\n",
               eta, alpha);
}

//---------------------------------------------------------------------------
NaStdBackProp::NaStdBackProp (NaNNUnit& rNN)
: nn(rNN)
{
    unsigned    /*iInput, iNeuron, */iLayer;

    // Assign dimensions
    for(iLayer = nn.InputLayer(); iLayer <= nn.OutputLayer(); ++iLayer){
        psWeight[iLayer].new_dim(nn.Neurons(iLayer), nn.Inputs(iLayer));
        psBias[iLayer].new_dim(nn.Neurons(iLayer));
        dWeight[iLayer].new_dim(nn.Neurons(iLayer), nn.Inputs(iLayer));
        dBias[iLayer].new_dim(nn.Neurons(iLayer));
        delta[iLayer].new_dim(nn.Neurons(iLayer));
        delta_prev[iLayer].new_dim(nn.Neurons(iLayer));
    }

    // Initalize all values by zero
    for(iLayer = nn.InputLayer(); iLayer <= nn.OutputLayer(); ++iLayer){
        psWeight[iLayer].init_zero();
        psBias[iLayer].init_zero();
        dWeight[iLayer].init_zero();
        dBias[iLayer].init_zero();
        delta[iLayer].init_zero();
        delta_prev[iLayer].init_zero();
    }
}

//---------------------------------------------------------------------------
NaStdBackProp::~NaStdBackProp ()
{
    // Dummy
}

//---------------------------------------------------------------------------
// Reset computed changes
void
NaStdBackProp::ResetNN ()
{
    unsigned    iLayer;
    // Reset dWeight and dBias for the next epoch
    for(iLayer = nn.InputLayer(); iLayer <= nn.OutputLayer(); ++iLayer){
        dWeight[iLayer].init_zero();
        dBias[iLayer].init_zero();
    }
}

//---------------------------------------------------------------------------
// Update network parameters on the basis of computed changes
void
NaStdBackProp::UpdateNN ()
{
    unsigned    iInput, iNeuron, iLayer;

#ifdef PrintUpdateNN
#define StdBPE_DEBUG
#endif /* PrintUpdateNN */

    // Apply dWeight and dBias to nn.weight and nn.bias
    for(iLayer = nn.InputLayer(); iLayer <= nn.OutputLayer(); ++iLayer){
#ifdef StdBPE_DEBUG
        NaMatrix    old_w(nn.weight[iLayer]);
        NaVector    old_b(nn.bias[iLayer]);
        NaPrintLog("=== Update layer[%u] ===\n", iLayer);
#endif // StdBPE_DEBUG
        for(iNeuron = 0; iNeuron < nn.Neurons(iLayer); ++iNeuron){
#ifdef StdBPE_DEBUG
            NaPrintLog("    Neuron[%u]:\n", iNeuron);
#endif // StdBPE_DEBUG
            for(iInput = 0; iInput < nn.Inputs(iLayer); ++iInput){
                psWeight[iLayer][iNeuron][iInput] =
                    dWeight[iLayer](iNeuron, iInput);
                nn.weight[iLayer][iNeuron][iInput] +=
                    dWeight[iLayer](iNeuron, iInput);
#ifdef StdBPE_DEBUG
                NaPrintLog("    * W[%u]= %g\t%+g\t--> %g\n",
                           iInput, old_w(iNeuron, iInput),
                           dWeight[iLayer](iNeuron, iInput),
                           nn.weight[iLayer](iNeuron, iInput));
#endif // StdBPE_DEBUG
            }
            psBias[iLayer][iNeuron] = dBias[iLayer][iNeuron];
            nn.bias[iLayer][iNeuron] += dBias[iLayer][iNeuron];
#ifdef StdBPE_DEBUG
            NaPrintLog("    * B= %g\t%+g\t--> %g\n",
                       old_b[iNeuron], dBias[iLayer][iNeuron],
                       nn.bias[iLayer][iNeuron]);
#endif // StdBPE_DEBUG
        }
    }

    // Reset dWeight and dBias for the next epoch
    ResetNN();

#ifdef PrintUpdateNN
#undef StdBPE_DEBUG
#endif /* PrintUpdateNN */
}

//---------------------------------------------------------------------------
// Compute delta weights based on common delta (see DeltaRule)
void
NaStdBackProp::ApplyDelta (unsigned iLayer)
{
    unsigned    iNeuron, iInput;

    // Apply delta weight and delta bias
#ifdef StdBPE_DEBUG
    NaMatrix    old_dW(dWeight[iLayer]);
    NaVector    old_dB(dBias[iLayer]);
    NaPrintLog("--- Applied delta for weight and bias [%u]-layer ---\n",
               iLayer);
#endif // StdBPE_DEBUG
    for(iNeuron = 0; iNeuron < nn.Neurons(iLayer); ++iNeuron){
#ifdef StdBPE_DEBUG
        NaPrintLog("    Neuron[%u]:\n", iNeuron);
#endif // StdBPE_DEBUG
        for(iInput = 0; iInput < nn.Inputs(iLayer); ++iInput){
            dWeight[iLayer][iNeuron][iInput] +=
                DeltaWeight(iLayer, iNeuron, iInput);
#ifdef StdBPE_DEBUG
            NaPrintLog("    * dW[%u]= %g\t--> %g\n",
                       iInput, old_dW(iNeuron, iInput),
                       dWeight[iLayer](iNeuron, iInput));
#endif // StdBPE_DEBUG
        }
        dBias[iLayer][iNeuron] += DeltaBias(iLayer, iNeuron);
#ifdef StdBPE_DEBUG
        NaPrintLog("    * dB= %g\t--> %g\n",
                   old_dB[iNeuron], dBias[iLayer][iNeuron]);
#endif // StdBPE_DEBUG
    }
}


//---------------------------------------------------------------------------
// Delta rule for the last layer.
// Ytarg is desired vector needs to be compared with Yout
// of the output layer or error value already computed..
// If bError==true then Ytarg means error ready to use without Yout.
// If bError==false then Ytarg means Ydes to compare with Yout.
void
NaStdBackProp::DeltaRule (const NaReal* Ytarg, bool bError)
{
    NaReal      fError;
    unsigned    iNeuron, iLayer = nn.OutputLayer();

#ifdef StdBPE_DEBUG
    NaPrintLog("+++ Standard delta rule [%u]-output +++\n", iLayer);
#endif // StdBPE_DEBUG

    if(NULL == Ytarg)
        throw(na_null_pointer);

    // Compute common delta
    for(iNeuron = 0; iNeuron < nn.Neurons(iLayer); ++iNeuron){
        // Compute error by comparing values Ydes and Yout
        if(bError){
	  // I still don't know whether precomputed error needs to be
	  // scaled the same manner as desired value or not.  Anyway
	  // I'm sure this bit of code (with disabled error scaling)
	  // is good enough to work in real application with outputs
	  // without scaling.  Don't scale NN outputs until you will
	  // be sure about proper way to scale precomputed error too!
#if 1
            // Error must not be scaled
            fError = Ytarg[iNeuron];
#else
            // Error must be scaled to standard range too
	    nn.ScaleData(nn.OutputScaler, nn.StdOutputRange,
			 &(Ytarg[iNeuron]), &fError, 1);
#endif
#ifdef StdBPE_DEBUG
            NaPrintLog("    ~ precomp.error[%d]= %g\n", iNeuron, fError);
#endif // StdBPE_DEBUG
        }else{
            NaReal  Ydes_i;

            // Scale Ydes to standard range [-1,1]
	    nn.ScaleData(nn.OutputScaler, nn.StdOutputRange,
			 &(Ytarg[iNeuron]), &Ydes_i, 1);

            fError = nn.Yout[iLayer][iNeuron] - Ydes_i;
#ifdef StdBPE_DEBUG
            NaPrintLog("    ~ error[%d]= %g\n", iNeuron, fError);
#endif // StdBPE_DEBUG
        }

        delta_prev[iLayer][iNeuron] = delta[iLayer][iNeuron];
        delta[iLayer][iNeuron] =
            fError * nn.DerivActFunc(iLayer, nn.Znet[iLayer][iNeuron]);
#ifdef StdBPE_DEBUG
        NaPrintLog("    * delta[%u]= %g\n", iNeuron, delta[iLayer][iNeuron]);
#endif // StdBPE_DEBUG
    }

    // Apply common delta - accumulate it in dWeight and dBias
    ApplyDelta(iLayer);
}


//---------------------------------------------------------------------------
// Part of delta rule for the hidden layer
// Computes sum of products outcoming weights and target deltas
// on given layer and for given input
NaReal
NaStdBackProp::PartOfDeltaRule (unsigned iPrevLayer, unsigned iInput)
{
    unsigned    iPrevNeuron;
    NaReal      fSum = 0.;

    for(iPrevNeuron = 0;
        iPrevNeuron < nn.Neurons(iPrevLayer);
        ++iPrevNeuron){
#ifdef StdBPE_DEBUG
        NaPrintLog("    ** [%u]: prev_delta= %g,  weight= %g\n",
                   iPrevNeuron, delta[iPrevLayer][iPrevNeuron],
                   nn.weight[iPrevLayer](iPrevNeuron, iInput));
#endif // StdBPE_DEBUG
        fSum += delta[iPrevLayer][iPrevNeuron] *
            nn.weight[iPrevLayer](iPrevNeuron, iInput);
    }

    return fSum;
}


//---------------------------------------------------------------------------
// Delta rule for the hidden layer
// iLayer - index of target layer delta computation on the basis of previous
// layer's delta and linked weights.  Usually iPrevLayer=iLayer+1.
void
NaStdBackProp::DeltaRule (unsigned iLayer, unsigned iPrevLayer)
{
    unsigned    iNeuron;

#ifdef StdBPE_DEBUG
    NaPrintLog("+++ Standard delta rule [%u]-hidden [%u]-previous +++\n",
               iLayer, iPrevLayer);
#endif // StdBPE_DEBUG

    // For each neuron of the current layer...
    for(iNeuron = 0;
        iNeuron < nn.Neurons(iLayer);
        ++iNeuron){
        // Store delta for future usage...
        delta_prev[iLayer][iNeuron] = delta[iLayer][iNeuron];
        // Initialize delta...
        delta[iLayer][iNeuron] = PartOfDeltaRule(iPrevLayer, iNeuron);
#ifdef StdBPE_DEBUG
        NaPrintLog("    * sum delta= %g,  Znet= %g,  Deriv= %g\n",
                   delta[iLayer][iNeuron], nn.Znet[iLayer][iNeuron],
                   nn.DerivActFunc(iLayer, nn.Znet[iLayer][iNeuron]));
#endif // StdBPE_DEBUG
        // Mulitply delta by derivation of the activation function
        delta[iLayer][iNeuron] *=
            nn.DerivActFunc(iLayer, nn.Znet[iLayer][iNeuron]);
#ifdef StdBPE_DEBUG
        NaPrintLog("    * delta[%u]= %g\n", iNeuron, delta[iLayer][iNeuron]);
#endif // StdBPE_DEBUG
    }

    // Apply common delta - accumulate it in dWeight and dBias
    ApplyDelta(iLayer);
}


//---------------------------------------------------------------------------
// Compute delta of exact w[i,j,k]
NaReal
NaStdBackProp::DeltaWeight (unsigned iLayer, unsigned iNeuron,
                            unsigned iInput)
{
    return - nn.Xinp(iLayer)(iInput) *
        delta[iLayer][iNeuron] * LearningRate(iLayer) +
        Momentum(iLayer) * psWeight[iLayer][iNeuron][iInput];
}


//---------------------------------------------------------------------------
// Compute delta of exact b[i,j]
NaReal
NaStdBackProp::DeltaBias (unsigned iLayer, unsigned iNeuron)
{
    return - delta[iLayer][iNeuron] * LearningRate(iLayer) +
        Momentum(iLayer) * psBias[iLayer][iNeuron];
}


//---------------------------------------------------------------------------
// Learning rate coefficient for the given layer
NaReal
NaStdBackProp::LearningRate (unsigned iLayer) const
{
    if(afkLinear == nn.descr.eLastActFunc &&
       nn.OutputLayer() == iLayer){
       // Last layer -> do special (usually very slow) learning
       return eta_output;
    }
    return NaStdBackPropParams::LearningRate(iLayer);
}


//---------------------------------------------------------------------------
