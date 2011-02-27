//-*-C++-*-
/* NaPNNNCo.h */
//---------------------------------------------------------------------------
#ifndef NaPNNNCoH
#define NaPNNNCoH

#include <NaPNNNUn.h>
#include <NaPNDely.h>
#include <NaPNBu12.h>
#include <NaPNBu21.h>

//---------------------------------------------------------------------------
// Applied Petri net node: neural net controller unit with related units.
// Has one input and one output of the neural network unit.
// ATTENTION! Input dimension must be 2 and output dimension must be 1!

//---------------------------------------------------------------------------
class NaPNNNController : public NaPetriNode
{
public:

    // Create node for Petri network
    NaPNNNController (const char* szNodeName = "nncontroller");


    //////////////////
    // Inside nodes //
    //////////////////

    NaPNBus1i2o		split_er;
    NaPNDelay		delay_e;
    NaPNDelay		delay_r;
    NaPNBus2i1o		merge_er;
    NaPNNNUnit		nnunit;

    ////////////////
    // Connectors //
    ////////////////

    // Input (mainstream)
    NaPetriCnInput	&x;

    // Output (mainstream) - nnunit.y
    NaPetriCnOutput	&y;


    ///////////////////
    // Node specific //
    ///////////////////

    // Assign new neural net unit
    void	set_nn_unit (NaNNUnit* pNN);

    // Get neural net unit pointer
    NaNNUnit*	get_nn_unit () {
	return nnunit.get_nn_unit();
    }

    // For compatibility reason
    void	set_transfer_func (NaNNUnit* pNN) {
	nnunit.set_transfer_func(pNN);
    }

    // Request state storage
    void	need_nn_deck (bool bDeckRequest, unsigned nSkipFirst = 0) {
	nnunit.need_nn_deck(bDeckRequest, nSkipFirst);
    }

    // Put actual state of NN to the deck (first-in first-out)
    void	push_nn () {
	nnunit.push_nn();
    }

    // Get the most ancient state of NN from the deck (first-in first-out)
    void	pop_nn (NaNNUnit& nn) {
	nnunit.pop_nn(nn);
    }

    ///////////////////////
    // Phases of network //
    ///////////////////////

    // 5. Verification to be sure all is OK (true)
    virtual bool        verify ();

protected:/* methods */

    // Called once when the node becomes part of network and when
    // net() started to be not NULL
    virtual void	attend_net ();

};


//---------------------------------------------------------------------------
#endif
