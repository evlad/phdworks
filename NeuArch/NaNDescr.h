//-*-C++-*-
/* NaNDescr.h */
/* $Id: NaNDescr.h,v 1.6 2001-05-15 06:02:21 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaNDescrH
#define NaNDescrH
//---------------------------------------------------------------------------

#include <NaGenerl.h>
#include <NaExcept.h>
#include <NaLogFil.h>
#include <NaConfig.h>
#include <NaVector.h>


//---------------------------------------------------------------------------
// For applied neural networks: Kind of controller
enum NaControllerKind
{
  NaLinearContr,
  NaNeuralContrDelayedE,
  NaNeuralContrER
};


//---------------------------------------------------------------------------
// For applied neural networks: Kind of algorithm
enum NaAlgorithmKind
{
  NaTrainingAlgorithm,	// learn
  NaEvaluationAlgorithm	// test
};


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
// Class for neural network description
class NaNeuralNetDescr: public NaLogging, public NaConfigPart
{
public:/* data */

    // Number of hidden layers (up to NaMAX_HIDDEN)
    unsigned    nHidLayers;

    // Number of neurons in each hidden layer
    unsigned    nHidNeurons[NaMAX_HIDDEN];

    // Dimension of input (1 by default)
    unsigned    nInputsNumber;

    // Memory for inputs: X(t), X(t-1),... (1 by default)
    unsigned    nInputsRepeat;

    // Memory for outputs: Y(t), Y(t-1),... (0 by default)
    unsigned    nOutputsRepeat;

    // Depth of feedback loop (dynamic; 0 by default, not limited)
    unsigned    nFeedbackDepth;

    // Dimension of output (1 by default)
    unsigned    nOutNeurons;

    // Activation function in the last layer
    NaActFuncKind   eLastActFunc;

    // Values of delays for input memory
    NaVector	vInputDelays;

    // Values of delays for output memory
    NaVector	vOutputDelays;

public:/* methods */

    NaNeuralNetDescr (unsigned nIn = 1, unsigned nOut = 1);
    NaNeuralNetDescr (const NaNeuralNetDescr& rDescr);
    virtual ~NaNeuralNetDescr ();

    unsigned    InputsNumber () const{
        return nInputsNumber * nInputsRepeat + nOutNeurons * nOutputsRepeat;
    }

    unsigned	MaxInputDelay () const;
    unsigned	MaxOutputDelay () const;

    unsigned*	InputDelays () const;
    unsigned*	OutputDelays () const;


    NaNeuralNetDescr&   operator= (const NaNeuralNetDescr& rDescr);

    bool    operator== (const NaNeuralNetDescr& rDescr) const;
    bool    operator!= (const NaNeuralNetDescr& rDescr) const{
        return !operator==(rDescr);
    }

    virtual void    PrintLog () const;

    //***********************************************************************
    // Store and retrieve configuration data
    //***********************************************************************

    // Store configuration data in internal order to given stream
    virtual void    Save (NaDataStream& ds);

    // Retrieve configuration data in internal order from given stream
    virtual void    Load (NaDataStream& ds);

};


//---------------------------------------------------------------------------
#endif
