/* NaPNTchr.cpp */
static char rcsid[] = "$Id: NaPNTchr.cpp,v 1.8 2001-12-13 12:27:15 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaPNTchr.h"


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNTeacher::NaPNTeacher (const char* szNodeName)
  : NaPetriNode(szNodeName), nAutoUpdateFreq(0), auProc(NULL),
  nn(NULL),
  bpe(NULL),  
  ////////////////
  // Connectors //
  ////////////////
  nnout(this, "nnout"),
  desout(this, "desout"),
  errout(this, "errout"),
  errinp(this, "errinp")
{
    // Nothing to do
}


//---------------------------------------------------------------------------
// Destroy the node
NaPNTeacher::~NaPNTeacher ()
{
    delete bpe;
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Set up procedure which will be executed each time the updating
// will take place
void
NaPNTeacher::set_auto_update_proc (void (*proc)(int, void*), void* data)
{
  auProc = proc;
  pData = data;
}


//---------------------------------------------------------------------------
// Set up updating frequency; 0 (no update) by default
void
NaPNTeacher::set_auto_update_freq (int nFreq)
{
  nAutoUpdateFreq = nFreq;

  if(0 != nAutoUpdateFreq && nLastUpdate >= nAutoUpdateFreq)
    update_nn();
}


//---------------------------------------------------------------------------
// Set link with neural net unit to teach it
void
NaPNTeacher::set_nn (NaNNUnit* pNN)
{
    check_tunable();

    if(NULL == pNN)
        throw(na_null_pointer);

    nn = pNN;

    // Create a teacher
    if(NULL != bpe)
        delete bpe;
    bpe = new NaStdBackProp(*nn);
    //qprop: bpe = new NaQuickProp(*nn);
    if(NULL == bpe)
        throw(na_bad_alloc);
}


//---------------------------------------------------------------------------
// Reset NN weight changes
void
NaPNTeacher::reset_nn ()
{
    if(NULL != bpe){
        bpe->ResetNN();
    }
}


//---------------------------------------------------------------------------
// Update NN weights
void
NaPNTeacher::update_nn ()
{
    if(NULL != bpe){
        bpe->UpdateNN();
	nLastUpdate = 0;
	++iUpdateCounter;
    }
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNTeacher::relate_connectors ()
{
    errinp.data().new_dim(nn->InputDim());
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNTeacher::verify ()
{
    if(NULL == nn){
        NaPrintLog("VERIFY FAILED: No NN is set!\n");
        return false;
    }else if(nnout.links() != 0 && desout.links() != 0 && errout.links() == 0){
        // Input pack #1
        return nn->OutputDim() == nnout.data().dim()
            && nn->OutputDim() == desout.data().dim()
            && nn->InputDim() == errinp.data().dim();
    }else if(nnout.links() == 0 && desout.links() == 0 && errout.links() != 0){
        // Input pack #2
        return nn->OutputDim() == errout.data().dim()
            && nn->InputDim() == errinp.data().dim();
    }
    NaPrintLog("VERIFY FAILED: "
               "'nnout' & 'desout' or 'errout' must be linked!\n");
    return false;
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNTeacher::initialize (bool& starter)
{
    starter = false;
    iUpdateCounter = 0;

    // Assign parameters
    *(NaStdBackPropParams*)bpe = lpar;
    //qprop: *(NaQuickPropParams*)bpe = lpar;
}


//---------------------------------------------------------------------------
// 7. Do one step of node activity and return true if succeeded
bool
NaPNTeacher::activate ()
{
    bool    bInputDataReady;
    if(errout.links() == 0){
        // Input pack #1
        bInputDataReady = !desout.is_waiting() && !nnout.is_waiting();
    }else{
        // Input pack #2
        bInputDataReady = !errout.is_waiting();
    }
    return bInputDataReady && !errinp.is_waiting();
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNTeacher::action ()
{
    unsigned    iLayer;
    unsigned    iInpLayer = nn->InputLayer();

    // One more activations since last update
    ++nLastUpdate;

    for(iLayer = nn->OutputLayer(); (int)iLayer >= (int)iInpLayer; --iLayer){
        if(nn->OutputLayer() == iLayer){
            // Output layer
            if(errout.links() == 0){
                // Input pack #1
                // Doesn't really need nnout due to it's stored inside NN
                bpe->DeltaRule(&desout.data()[0]);
            }else{
                // Input pack #2
                bpe->DeltaRule(&errout.data()[0], true);
            }
        }else{
            // Hidden layer
            bpe->DeltaRule(iLayer, iLayer + 1);
        }
    }// backward step

    // Compute error on input
    if(errinp.links() > 0){
        unsigned    iInput;
        NaVector    &einp = errinp.data();

        einp.init_zero();
        for(iInput = 0; iInput < einp.dim(); ++iInput){
            einp[iInput] -= bpe->PartOfDeltaRule(iInpLayer, iInput);
        }
    }

    // Autoupdate facility
    if(0 != nAutoUpdateFreq && nLastUpdate >= nAutoUpdateFreq){
      NaPrintLog("Automatic update #%d of NN (%d sample)\n",
		 iUpdateCounter, activations());
      update_nn();

      // Call procedure
      if(NULL != auProc)
	(*auProc)(iUpdateCounter, pData);
    }
}


//---------------------------------------------------------------------------
// 9. Finish data processing by the node (if activate returned true)
void
NaPNTeacher::post_action ()
{
    if(errout.links() == 0){
        // Input pack #1
        desout.commit_data();
        nnout.commit_data();
    }else{
        // Input pack #2
        errout.commit_data();
    }
    errinp.commit_data();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
