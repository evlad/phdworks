//-*-C++-*-
/* NaMath.h */
/* $Id: NaMath.h,v 1.2 2001-05-15 06:02:21 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaMathH
#define NaMathH

#include <NaGenerl.h>


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
 
