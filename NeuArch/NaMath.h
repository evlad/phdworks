//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaMathH
#define NaMathH

#include "NaGenerl.h"


//---------------------------------------------------------------------------

//////////////////////////////
// Random number generation //
//////////////////////////////

extern "C" {

// Setup random generator from the system timer
void            reset_rand ();

// Unified destributed random number
NaReal          rand_unified (NaReal fMin, NaReal fMax);

// Gaussian normal random number distribution
NaReal          rand_gaussian (NaReal fMean, NaReal fStdDev);

};

//---------------------------------------------------------------------------
#endif
 
