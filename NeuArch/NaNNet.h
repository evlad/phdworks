//-*-C++-*-
/* NaNNet.h */
/* $Id: NaNNet.h,v 1.2 2001-05-15 06:02:21 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaNNetH
#define NaNNetH

#include <NaUnit.h>
#include <NaVector.h>
#include <NaMatrix.h>
#include <NaConfig.h>

//---------------------------------------------------------------------------
// Kind of activation function
enum NaActFuncKind
{
    afkLinear = 0,  // Linear function
    afkTanH,        // Squashing function

    __afkNumber
};

//---------------------------------------------------------------------------
const char*     NaActFuncToStrIO (NaActFuncKind eAFK);
NaActFuncKind   NaStrToActFuncIO (const char* s);


//---------------------------------------------------------------------------
// Class for neural network representation.
class NaNeuralNet : public NaUnit, public NaConfigPart
{
public:

    NaNeuralNet (unsigned nInputs = 1, unsigned nOutputs = 1,
                 unsigned nHidLayers = 0, unsigned nHidden[] = NULL,
                 bool bFeedback = false);
    NaNeuralNet (const NaNeuralNet& rNNet);
    virtual ~NaNeuralNet ();

    // Assign the object
    NaNeuralNet&    operator= (const NaNeuralNet& rNNet);

    //***********************************************************************
    // Store and retrieve configuration data
    //***********************************************************************

    // Store configuration data in internal order to given stream
    virtual void    Save (NaDataStream& ds);

    // Retrieve configuration data in internal order from given stream
    virtual void    Load (NaDataStream& ds);

    //==================\\
    // NaUnit inherited \\
    //==================\\

    // Reset operations, that must be done before new modelling
    // will start
    virtual void    Reset ();

    // Compute output on the basis of internal parameters,
    // stored state and external input: y=F(x,t,p)
    virtual void    Function (NaReal* x, NaReal* y);

    // Supply unit with feedback values on the first step of
    // unit perfomance.  All needed feedback values are stored.
    virtual void    FeedbackValues (NaReal* fb);

    //=====================\\
    // NaLogging inherited \\
    //=====================\\

    virtual void    PrintLog () const;

    //====================\\
    // New data & methods \\
    //====================\\

    // Return number of parameter records (see layers)
    unsigned        Layers () const;

    // Return number of neurons in given layer
    unsigned        Neurons (unsigned iLayer) const;

    // Return number of inputs of given layer
    // If feedback exists then Inputs(InputLayer())!=InputDim()
    unsigned        Inputs (unsigned iLayer) const;

    // Index of the first avaiable (input) NN hidden layer
    unsigned        InputLayer () const;

    // Index of the last (output) NN layer
    unsigned        OutputLayer () const;

    //================\\
    // NN description \\
    //================\\

    // Number of hidden layers (0..NaMAX_HIDDEN)
    unsigned        hidlayers;

    // Activation function of the last layer
    NaActFuncKind   eLastActFunc;

    // If feedback is true then InputDim()=Inputs(InputLayer())+OutputDim()
    // else InputDim()=Inputs(InputLayer())
    bool            feedback;

    // Parameters of the network (0.layers()-1)
    NaMatrix        weight[NaMAX_HIDDEN+1];
    NaVector        bias[NaMAX_HIDDEN+1];

    // Results of the computation
    NaVector&       Xinp (unsigned iLayer); // input of the layer
    NaVector        Xinp0;                  // input of the first layer
    NaVector        Yout[NaMAX_HIDDEN+1];   // after ActFunc
    NaVector        Znet[NaMAX_HIDDEN+1];   // before ActFunc

    // Compute activation function for the given layer
    virtual NaReal	ActFunc (unsigned iLayer, NaReal z);

    // Compute derivation of activation function
    virtual NaReal	DerivActFunc (unsigned iLayer, NaReal z);

    // Initialize weights and biases
    virtual void	Initialize ();

    // Jog weights and biases
    virtual void	JogNetwork (NaReal mm);

    //==================\\
    // I/O data scaling \\
    //==================\\

    // Scaler of the output layer
    struct NaScaler {
        NaVector    min;
        NaVector    max;
    }               InputScaler, OutputScaler, StdInputRange, StdOutputRange;

    // Set output scale: [-1,1] -> [yMin,yMax]
    virtual void    SetOutputScale (const NaReal* yMin, const NaReal* yMax);

    // Set input scale: [yMin,yMax] -> [-1,1]
    virtual void    SetInputScale (const NaReal* yMin, const NaReal* yMax);

    // Scale given vector; maybe pSrcVect==pDstVect
    virtual void    ScaleData (const NaNeuralNet::NaScaler& rSrcScaler,
                               const NaNeuralNet::NaScaler& rDstScaler,
                               const NaReal* pSrcVect,
                               NaReal* pDstVect,
                               unsigned nDim) const;

};

//---------------------------------------------------------------------------
#endif
