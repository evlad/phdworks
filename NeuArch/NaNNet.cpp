/* NaNNet.cpp */
static char rcsid[] = "$Id: NaNNet.cpp,v 1.3 2001-11-25 21:35:22 vlad Exp $";
//---------------------------------------------------------------------------

#include <string.h>
#include <math.h>

#include "NaNNet.h"

//---------------------------------------------------------------------------
const char*
NaActFuncToStrIO (NaActFuncKind eAFK)
{
    switch(eAFK){

    case afkLinear:
        return "linear";
    case afkTanH:
        return "tanh";
    }
    return "???";
}

//---------------------------------------------------------------------------
NaActFuncKind
NaStrToActFuncIO (const char* s)
{
    if(NULL == s)
        throw(na_null_pointer);

    if(!strcmp(NaActFuncToStrIO(afkLinear), s))
        return afkLinear;
    else if(!strcmp(NaActFuncToStrIO(afkTanH), s))
        return afkTanH;
    return __afkNumber;
}

//---------------------------------------------------------------------------
NaNeuralNet::NaNeuralNet (unsigned nInputs, unsigned nOutputs,
                          unsigned nHidLayers, unsigned nHidden[],
                          bool bFeedback)
: NaConfigPart("NeuralNet")
{
}

//---------------------------------------------------------------------------
NaNeuralNet::NaNeuralNet (const NaNeuralNet& rNNet)
: NaConfigPart(rNNet)
{
}


//---------------------------------------------------------------------------
NaNeuralNet::~NaNeuralNet ()
{
}


//---------------------------------------------------------------------------
// Assign the object
NaNeuralNet&
NaNeuralNet::operator= (const NaNeuralNet& rNNet)
{
    return *this;
}


//---------------------------------------------------------------------------

//***********************************************************************
// Store and retrieve configuration data
//***********************************************************************

//---------------------------------------------------------------------------
// Store configuration data in internal order to given stream
void
NaNeuralNet::Save (NaDataStream& ds)
{
#if 0
    char        szBuf[80];
    unsigned    iLayer, iNeuron, iInput;

    descr.Save(ds);

    ds.PutComment("Neural network:");

    ds.PutF("Number of inputs", "%u", Inputs(InputLayer()));
    ds.PutF("Feedback depth", "%d", true==feedback);
    ds.PutF("Output act.function", "%s", NaActFuncToStrIO(eLastActFunc));
    ds.PutF("Number of hidden layers", "%u", hidlayers);

    for(iLayer = InputLayer(); iLayer < OutputLayer(); ++iLayer)
        ds.PutF("Hidden layer", "%u", Outputs(iLayer));
    ds.PutF("Output layer", "%u", Outputs(OutputLayer()));

    for(iLayer = InputLayer(); iLayer <= OutputLayer(); ++iLayer){
        sprintf(szBuf, "Layer #%u  (%u inputs, %u neurons)",
                iLayer, Inputs(iLayer), Outputs(iLayer));
        ds.PutComment(szBuf);
        for(iNeuron = 0; iNeuron < Outputs(iLayer); ++iNeuron){
            sprintf(szBuf, "Neuron #%u (bias / weights):", iNeuron);
            ds.PutF(szBuf, "%g", bias[iLayer](iNeuron));
            for(iInput = 0; iInput < Inputs(iLayer); ++iInput){
                ds.PutF(NULL, "%g", weight[iLayer](iNeuron, iInput));
            }// for inputs of neuron
        }// for neurons of layer
    }// for layers

    ds.PutComment("Input scaler:");
    for(iInput = 0; iInput < (unsigned)InputDim(); ++iInput){
        ds.PutF("min max", "%g %g",
                InputScaler.min(iInput), InputScaler.max(iInput));
    }

    ds.PutComment("Output scaler:");
    for(iNeuron = 0; iNeuron < (unsigned)OutputDim(); ++iNeuron){
        ds.PutF("min max", "%g %g",
                OutputScaler.min(iNeuron), OutputScaler.max(iNeuron));
    }
#endif
}

//---------------------------------------------------------------------------
// Retrieve configuration data in internal order from given stream
void
NaNeuralNet::Load (NaDataStream& ds)
{
#if 0
    unsigned    iLayer, iNeuron, iInput;

    NaNeuralNetDescr    rTmpDescr;
    rTmpDescr.Load(ds);
    AssignDescr(rTmpDescr);

    for(iLayer = InputLayer(); iLayer <= OutputLayer(); ++iLayer){
        for(iNeuron = 0; iNeuron < weight[iLayer].dim_rows(); ++iNeuron){
            ds.GetF("%lg", &bias[iLayer][iNeuron]);
            for(iInput = 0; iInput < weight[iLayer].dim_cols(); ++iInput){
                ds.GetF("%lg", &weight[iLayer][iNeuron][iInput]);
            }// for inputs of neuron
        }// for neurons of layer
    }// for layers

    for(iInput = 0; iInput < (unsigned)InputDim(); ++iInput){
        ds.GetF("%lg %lg",
                &InputScaler.min[iInput], &InputScaler.max[iInput]);
    }
    for(iNeuron = 0; iNeuron < (unsigned)OutputDim(); ++iNeuron){
        ds.GetF("%lg %lg",
                &OutputScaler.min[iNeuron], &OutputScaler.max[iNeuron]);
    }
#endif
}


//---------------------------------------------------------------------------

//==================
// NaUnit inherited 
//==================

//---------------------------------------------------------------------------
// Reset operations, that must be done before new modelling
// will start
void
NaNeuralNet::Reset ()
{
    // Dummy
}

//---------------------------------------------------------------------------
// Compute output on the basis of internal parameters,
// stored state and external input: y=F(x,t,p)
void
NaNeuralNet::Function (NaReal* x, NaReal* y)
{
#if 0
    unsigned    i, j;

    /***** Direct part *****/

#ifdef NNUnit_DEBUG
    NaPrintLog("NN function:\n");
#endif // NNUnit_DEBUG

    // Store x for input layer...
    for(i = 0; i < InputDim(); ++i){
        Xinp0[i] = x[i];
#ifdef NNUnit_DEBUG
        NaPrintLog("  * direct   in[%u] = %g\n", i, Xinp0[i]);
#endif // NNUnit_DEBUG
    }

    // Scale input vector
    ScaleData(InputScaler, StdInputRange, &Xinp0[0], &Xinp0[0],
              InputDim());

#ifdef NNUnit_DEBUG
    for(i = 0; i < InputDim(); ++i){
        NaPrintLog("  * scaled   in[%u] = %g\n", i, Xinp0[i]);
    }
#endif // NNUnit_DEBUG

    // ...plus stored (and scaled) feedback values
    for(i = 0; i < feedback.dim(); ++i){
        Xinp0[InputDim() + i] = feedback[i];
#ifdef NNUnit_DEBUG
        NaPrintLog("  * feedback in[%u] = %g\n",
                   InputDim() + i, Xinp0[InputDim() + i]);
#endif // NNUnit_DEBUG
    }

    // Compute y=f(x, fb)
    unsigned    iLayer, iNeuron, iInput;

    for(iLayer = InputLayer(); iLayer <= OutputLayer(); ++iLayer){

#ifdef NNUnit_DEBUG
        NaPrintLog("  + Layer %u\n", iLayer);
#endif // NNUnit_DEBUG

        for(iNeuron = 0; iNeuron < Neurons(iLayer); ++iNeuron){

#ifdef NNUnit_DEBUG
            NaPrintLog("    + Neuron %u\n", iNeuron);
#endif // NNUnit_DEBUG

            Znet[iLayer][iNeuron] = bias[iLayer][iNeuron];  // sum

#ifdef NNUnit_DEBUG
            NaPrintLog("      ! Bias= %g\n", Znet[iLayer][iNeuron]);
#endif // NNUnit_DEBUG

            for(iInput = 0; iInput < Inputs(iLayer); ++iInput){
                Znet[iLayer][iNeuron] +=
                    Xinp(iLayer)(iInput) * weight[iLayer](iNeuron, iInput);
#ifdef NNUnit_DEBUG
                NaPrintLog("      !! Xinp= %g,  W= %g,  Znet= %g\n",
                           Xinp(iLayer)(iInput),
                           weight[iLayer](iNeuron, iInput),
                           Znet[iLayer][iNeuron]);
#endif // NNUnit_DEBUG
            }// for inputs of the neuron

#ifdef NNUnit_DEBUG
            NaPrintLog("      ! Znet= %g\n", Znet[iLayer][iNeuron]);
#endif // NNUnit_DEBUG

            Yout[iLayer][iNeuron] = ActFunc(iLayer, Znet[iLayer][iNeuron]);

#ifdef NNUnit_DEBUG
            NaPrintLog("      ! Yout= %g\n", Yout[iLayer][iNeuron]);
#endif // NNUnit_DEBUG

        }// for neurons of the layer

    }// for layers

    // Store Yout of the last layer to output y
    for(i = 0; i < OutputDim(); ++i){
        y[i] = Yout[OutputLayer()][i];
    }

    // Check for feedback
    if(0 != FeedbackDepth()){

        /**** Feedback part ****/

        // Shift delayed feedback values
        for(i = 1; i < FeedbackDepth(); ++i)
            for(j = 0; j < OutputDim(); ++j)
                feedback[(i - 1) * OutputDim() + j] =
                    feedback[i * OutputDim() + j];

        // Store y to fb and scale fb to the standard input scale
        i = FeedbackDepth() - 1;
        ScaleData(StdOutputRange, StdInputRange,
                  y, &feedback[i * OutputDim()], OutputDim());
    }

    // Scale output vector
    ScaleData(StdOutputRange, OutputScaler, y, y, OutputDim());

#ifdef NNUnit_DEBUG
    // Print resulting output
    for(i = 0; i < OutputDim(); ++i)
        NaPrintLog("  * direct  out[%u] = %g\n", i, y[i]);
#endif // NNUnit_DEBUG
#endif
}

//---------------------------------------------------------------------------
// Supply unit with feedback values on the first step of
// unit perfomance.  All needed feedback values are stored.
void
NaNeuralNet::FeedbackValues (NaReal* fb)
{
#if 0
    if(NULL == fb)
        throw(na_null_pointer);

    if(0 == FeedbackDepth())
        // No need for feedback values
        return;

#if 0
    unsigned    i, j;

    for(i = 0; i < FeedbackDepth(); ++i)
        for(j = 0; j < OutputDim(); ++j)
            feedback[i * OutputDim() + j] = fb[i * OutputDim() + j];
#endif

    // Scale output vector
    ScaleData(OutputScaler, StdInputRange, fb, &feedback[0],
              OutputDim() * FeedbackDepth());
#endif
}

//---------------------------------------------------------------------------

//=====================
// NaLogging inherited 
//=====================

//---------------------------------------------------------------------------
void
NaNeuralNet::PrintLog () const
{
#if 0
    unsigned    iLayer, iNeuron, iInput;

    NaPrintLog("NaNeuralNet(this=%p):\n  includes ", this);
    descr.PrintLog();
    NaUnit::PrintLog();
    NaPrintLog("  network has the next tunable parameters:\n");

    for(iLayer = InputLayer(); iLayer <= OutputLayer(); ++iLayer){
        NaPrintLog("  * layer #%u (%u inputs, %u neurons)\n", iLayer,
                   weight[iLayer].dim_cols(),
                   weight[iLayer].dim_rows());
        for(iNeuron = 0; iNeuron < weight[iLayer].dim_rows(); ++iNeuron){
            NaPrintLog("    * neuron #%u (bias / weights)\n      %+7.3f /",
                       iNeuron, bias[iLayer](iNeuron));
            for(iInput = 0; iInput < weight[iLayer].dim_cols(); ++iInput){
                NaPrintLog("\t%+6.3f", weight[iLayer](iNeuron, iInput));
            }// for inputs of neuron
            NaPrintLog("\n");
        }// for neurons of layer
    }// for layers
#endif
}

//---------------------------------------------------------------------------

//====================
// New data & methods 
//====================

//---------------------------------------------------------------------------
// Return number of parameter records (see layers)
unsigned
NaNeuralNet::Layers () const
{
    return hidlayers + 1/* output */;
}

//---------------------------------------------------------------------------
// Return number of neurons in given layer
unsigned
NaNeuralNet::Neurons (unsigned iLayer) const
{
    return weight[iLayer].dim_rows();
}

//---------------------------------------------------------------------------
// Return number of inputs of given layer
// If feedback exists then Inputs(InputLayer())!=InputDim()
unsigned
NaNeuralNet::Inputs (unsigned iLayer) const
{
    return weight[iLayer].dim_cols();
}

//---------------------------------------------------------------------------
// Index of the first avaiable (input) NN hidden layer
unsigned
NaNeuralNet::InputLayer () const
{
    return 0;
}

//---------------------------------------------------------------------------
// Index of the last (output) NN layer
unsigned
NaNeuralNet::OutputLayer () const
{
    return Layers() - 1;
}

//---------------------------------------------------------------------------
// Compute activation function for the given layer
NaReal
NaNeuralNet::ActFunc (unsigned iLayer, NaReal z)
{
    NaReal  f;
    if(OutputLayer() == iLayer && eLastActFunc == afkLinear){
        // Linear transfer
        f = z;
    }else{
         // Sigmoid
        f = tanh(z);
    }
    return f;
}

//---------------------------------------------------------------------------
NaReal
NaNeuralNet::DerivActFunc (unsigned iLayer, NaReal z)
{
    NaReal  f;
    if(OutputLayer() == iLayer && eLastActFunc == afkLinear){
        // Linear transfer derivation
        f = 1.;
    }
    else /* sigmoid */{
        f = ActFunc(iLayer, z);
        f = 0.5 * (1. - f * f);
    }
    return f;
}

//---------------------------------------------------------------------------
// Input of the layer
NaVector&
NaNeuralNet::Xinp (unsigned iLayer)
{
    if(InputLayer() == iLayer)
        return Xinp0;
    return Yout[iLayer-1];
}

//---------------------------------------------------------------------------
// Initialize weights and biases
void
NaNeuralNet::Initialize ()
{
#if 0
    unsigned    iLayer;

    for(iLayer = 0; iLayer < Layers(); ++iLayer){
        weight[iLayer].init_random(-0.2, 0.2);
        bias[iLayer].init_random(-0.2, 0.2);
    }// for layers
#endif
}

//---------------------------------------------------------------------------
// Jog weights and biases
void
NaNeuralNet::JogNetwork (NaReal mm)
{
#if 0
    NaRandomSequence    rSeq;
    unsigned    iLayer, iNeuron, iInput;

    NaReal  vMin, vMax, vRand;
    if(mm < 0){
        vMin = mm;
        vMax = - mm;
    }
    else{
        vMax = mm;
        vMin = - mm;
    }
    rSeq.SetUniformParams(vMin, vMax);
    rSeq.Reset();

    for(iLayer = InputLayer(); iLayer <= OutputLayer(); ++iLayer){
        for(iNeuron = 0; iNeuron < Neurons(iLayer); ++iNeuron){
            rSeq.Function(NULL, &vRand);
            bias[iLayer][iNeuron] += vRand;
            for(iInput = 0; iInput < Inputs(iLayer); ++iInput){
                rSeq.Function(NULL, &vRand);
                weight[iLayer][iNeuron][iInput] += vRand;
            }// for inputs of the neuron
        }// for neurons of the layer
    }// for layers
#endif
}

//---------------------------------------------------------------------------

//==================
// I/O data scaling 
//==================

//---------------------------------------------------------------------------
// Set output scale: [-1,1] -> [yMin,yMax]
void
NaNeuralNet::SetOutputScale (const NaReal* yMin, const NaReal* yMax)
{
#if 0
    if(NULL == yMin || NULL == yMax)
        throw(na_null_pointer);

    unsigned    i, j;
    unsigned    nTrueInputs = Inputs(InputLayer());
    unsigned    nOutputs = Outputs(OutputLayer());

    if(eLastActFunc == afkLinear){
        // No squashing but forcing to change around zero
        NaReal  yAvg;
        for(i = 0; i < nOutputs; ++i){
            yAvg = 0.5 * (yMin[i] + yMax[i]);
            OutputScaler.min[i] = yMin[i] - yAvg;
            OutputScaler.max[i] = yMax[i] - yAvg;
        }
        if(feedback){
            for(i = 0; i < nOutputs; ++i){
                yAvg = 0.5 * (yMin[i] + yMax[i]);
                InputScaler.min[i] = yMin[j] - yAvg;
                InputScaler.max[i] = yMax[i] - yAvg;
            }
        }

        for(i = 0; i < (true == feedback); ++i){
            for(j = 0; j < descr.nOutNeurons; ++j){
                yAvg = 0.5 * (yMin[j] + yMax[j]);
                InputScaler.min[base + i * descr.nOutNeurons + j] =
                    yMin[j] - yAvg;
                InputScaler.max[base + i * descr.nOutNeurons + j] =
                    yMax[j] - yAvg;
            }
        }
    }
    else{
        // Squashing
        for(i = 0; i < descr.nOutputsRepeat; ++i){
            for(j = 0; j < descr.nOutNeurons; ++j){
                InputScaler.min[base + i * descr.nOutNeurons + j] = yMin[j];
                InputScaler.max[base + i * descr.nOutNeurons + j] = yMax[j];
            }
        }
        for(j = 0; j < descr.nOutNeurons; ++j){
            OutputScaler.min[j] = yMin[j];
            OutputScaler.max[j] = yMax[j];
        }
    }
#endif
}


//---------------------------------------------------------------------------
// Set input scale: [yMin,yMax] -> [-1,1]
void
NaNeuralNet::SetInputScale (const NaReal* yMin, const NaReal* yMax)
{
#if 0
    if(NULL == yMin || NULL == yMax)
        throw(na_null_pointer);

    unsigned    i, j;
    for(i = 0; i < descr.nInputsRepeat; ++i){
        for(j = 0; j < descr.nInputsNumber; ++j){
            InputScaler.min[i * descr.nInputsNumber + j] = yMin[j];
            InputScaler.max[i * descr.nInputsNumber + j] = yMax[j];
        }
    }
#endif
}

//---------------------------------------------------------------------------
// Scale given vector; maybe pSrcVect==pDstVect
void
NaNeuralNet::ScaleData (const NaNeuralNet::NaScaler& rSrcScaler,
                        const NaNeuralNet::NaScaler& rDstScaler,
                        const NaReal* pSrcVect,
                        NaReal* pDstVect,
                        unsigned nDim) const
{
#if 0
    if(NULL == pSrcVect || NULL == pDstVect)
        throw(na_null_pointer);

    unsigned    i;
    for(i = 0; i < nDim; ++i){
        NaReal  fDstDiff = rDstScaler.max(i) - rDstScaler.min(i);
        NaReal  fSrcDiff = rSrcScaler.max(i) - rSrcScaler.min(i);

        // Preveint scaling if some difference is zero
        if(0 == fDstDiff)
            fDstDiff = 1.;
        if(0 == fSrcDiff)
            fSrcDiff = 1.;

        pDstVect[i] = rDstScaler.min(i) + (pSrcVect[i] - rSrcScaler.min(i)) *
            fDstDiff / fSrcDiff;
    }
#endif
}

//---------------------------------------------------------------------------
#pragma package(smart_init)
