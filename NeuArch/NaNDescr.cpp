//---------------------------------------------------------------------------

#include <string.h>

#include "NaNDescr.h"


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
void    NaNeuralNetDescr::PrintLog () const
{
    NaPrintLog("NaNeuralNetDescr(this=%p):\n  inputs=%u  outputs=%u"
               "  in.repeat=%u  out.repeat=%u  feedback=%u\n"
               "  %s last layer activation function\n"
               "  hidden layers %d total:\n", this,
               nInputsNumber, nOutNeurons, nInputsRepeat, nOutputsRepeat,
               nFeedbackDepth, NaActFuncToStrIO(eLastActFunc), nHidLayers);

    for(unsigned i = 0; i < nHidLayers; ++i)
        NaPrintLog("  * layer #%d has %d neurons\n", i, nHidNeurons[i]);
}

//---------------------------------------------------------------------------
NaNeuralNetDescr::NaNeuralNetDescr (unsigned nIn, unsigned nOut)
:   NaConfigPart("NeuralNetArchitecture")
{
    nHidLayers = 1;

    unsigned    i;
    for(i = 0; i < MAX_HIDDEN; ++i)
        if(i < nHidLayers)
            nHidNeurons[i] = 5;
        else
            nHidNeurons[i] = 0;

    nOutNeurons = nOut;
    nInputsNumber = nIn;
    nInputsRepeat = 1;
    nOutputsRepeat = 0;
    nFeedbackDepth = 0;
    eLastActFunc = afkLinear;
}

//---------------------------------------------------------------------------
NaNeuralNetDescr::NaNeuralNetDescr (const NaNeuralNetDescr& rDescr)
:   NaConfigPart(rDescr)
{
    nHidLayers = rDescr.nHidLayers;

    unsigned    i;
    for(i = 0; i < MAX_HIDDEN; ++i)
        if(i < nHidLayers)
            nHidNeurons[i] = rDescr.nHidNeurons[i];
        else
            nHidNeurons[i] = 0;

    nOutNeurons = rDescr.nOutNeurons;
    nInputsNumber = rDescr.nInputsNumber;
    nInputsRepeat = rDescr.nInputsRepeat;
    nOutputsRepeat = rDescr.nOutputsRepeat;
    nFeedbackDepth = rDescr.nFeedbackDepth;
    eLastActFunc = rDescr.eLastActFunc;
}

//---------------------------------------------------------------------------
NaNeuralNetDescr::~NaNeuralNetDescr ()
{
    // dummy
}

//***********************************************************************
// Store and retrieve configuration data
//***********************************************************************

//---------------------------------------------------------------------------
// Store configuration data in internal order to given stream
void    NaNeuralNetDescr::Save (NaDataStream& ds)
{
    ds.PutComment("Neural network architecture definition");
    ds.PutF("Number of inputs and their repeat factor", "%u %u",
            nInputsNumber, nInputsRepeat);
    ds.PutF("Output repeat factor on the input", "%u", nOutputsRepeat);
    ds.PutF("Feedback depth", "%u", nFeedbackDepth);
    ds.PutF("Number of hidden layers", "%u", nHidLayers);
    unsigned    i;
    for(i = 0; i < nHidLayers; ++i)
        ds.PutF("Hidden layer", "%u", nHidNeurons[i]);

    ds.PutF("Output layer", "%s %u",
            NaActFuncToStrIO(eLastActFunc), nOutNeurons);
}

//---------------------------------------------------------------------------
// Retrieve configuration data in internal order from given stream
void    NaNeuralNetDescr::Load (NaDataStream& ds)
{
    ds.GetF("%u %u", &nInputsNumber, &nInputsRepeat);
    ds.GetF("%u", &nOutputsRepeat);
    ds.GetF("%u", &nFeedbackDepth);
    ds.GetF("%u", &nHidLayers);
    unsigned    i;
    for(i = 0; i < nHidLayers; ++i){
        unsigned    neurons;
        ds.GetF("%u", &neurons);
        if(i < MAX_HIDDEN)
            nHidNeurons[i] = neurons;
    }
    if(nHidLayers > MAX_HIDDEN){
        nHidLayers = MAX_HIDDEN;
        NaPrintLog("Too many hidden layers: only %u are allowed\n",
                   MAX_HIDDEN);
    }

    char    szBuf[1024];

    ds.GetF("%s %u", szBuf, &nOutNeurons);
    eLastActFunc = NaStrToActFuncIO(szBuf);
}

//---------------------------------------------------------------------------
NaNeuralNetDescr&
NaNeuralNetDescr::operator= (const NaNeuralNetDescr& rDescr)
{
    nHidLayers = rDescr.nHidLayers;

    unsigned    i;
    for(i = 0; i < MAX_HIDDEN; ++i)
        if(i < nHidLayers)
            nHidNeurons[i] = rDescr.nHidNeurons[i];
        else
            nHidNeurons[i] = 0;

    nOutNeurons = rDescr.nOutNeurons;
    nInputsNumber = rDescr.nInputsNumber;
    nInputsRepeat = rDescr.nInputsRepeat;
    nOutputsRepeat = rDescr.nOutputsRepeat;
    nFeedbackDepth = rDescr.nFeedbackDepth;
    eLastActFunc = rDescr.eLastActFunc;

    return *this;
}

//---------------------------------------------------------------------------
bool
NaNeuralNetDescr::operator== (const NaNeuralNetDescr& rDescr) const
{
    if(nHidLayers != rDescr.nHidLayers)
        return false;

    bool    r = true;

    unsigned    i;
    for(i = 0; i < nHidLayers; ++i)
        r = r && (nHidNeurons[i] == rDescr.nHidNeurons[i]);

    r = r && (nOutNeurons == rDescr.nOutNeurons);
    r = r && (nInputsNumber == rDescr.nInputsNumber);
    r = r && (nInputsRepeat == rDescr.nInputsRepeat);
    r = r && (nOutputsRepeat == rDescr.nOutputsRepeat);
    r = r && (nFeedbackDepth == rDescr.nFeedbackDepth);
    r = r && (eLastActFunc == rDescr.eLastActFunc);

    return r;
}

//---------------------------------------------------------------------------

