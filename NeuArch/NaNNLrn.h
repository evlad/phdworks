//-*-C++-*-
/* NaNNLrn.h */
/* $Id: NaNNLrn.h,v 1.2 2001-05-15 06:02:21 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaNNLrnH
#define NaNNLrnH
//---------------------------------------------------------------------------

#include <NaStdBPE.h>
#include <NaQProp.h>


//---------------------------------------------------------------------------
// Learning algorithm
enum NaLearningAlg {

    laStdBPE = 0,   // standard BPE with momentum term
    laQuickProp,    // quick propagation
    __laNumber      // special meaning

};

// Learning parameters
struct NaLearningParams {

    NaStdBackPropParams     StdBPE;     // Parameters for BPE
    NaQuickPropParams       QProp;      // Parameters for QuickProp

};


//---------------------------------------------------------------------------
#endif

