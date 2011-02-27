/* NaPNNNCo.cpp */
//---------------------------------------------------------------------------

#include "NaPNNNCo.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNNNController::NaPNNNController (const char* szNodeName)
  : NaPetriNode(szNodeName),
    split_er("split_er"),
    delay_e("delay_e"),
    delay_r("delay_r"),
    merge_er("merge_er"),
    nnunit("nnunit"),
    ////////////////
    // Connectors //
    ////////////////
    x(split_er.in),
    y(nnunit.y)
{
    // Make e to be main input and r to be the rest
    split_er.set_out_dim_proportion(1, 0);
}


//---------------------------------------------------------------------------
// Called once when the node becomes part of network and when net()
// started to be not NULL
void
NaPNNNController::attend_net ()
{
    // Let's link internal nodes
    net()->link(&split_er.out1, &delay_e.in);
    net()->link(&split_er.out2, &delay_r.in);
    net()->link(&delay_e.dout, &merge_er.in1);
    net()->link(&delay_r.dout, &merge_er.in2);
    net()->link(&merge_er.out, &nnunit.x);
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Assign new neural net
void
NaPNNNController::set_nn_unit (NaNNUnit* pNN)
{
    nnunit.set_nn_unit(pNN);

    delay_e.set_delay(pNN->descr.nInputsRepeat, pNN->descr.InputDelays());
    delay_r.set_delay(pNN->descr.nOutputsRepeat, pNN->descr.OutputDelays());
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNNNController::verify ()
{
    return 2 == x.data().dim() && 1 == y.data().dim();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
