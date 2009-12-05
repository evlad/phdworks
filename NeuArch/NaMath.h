//-*-C++-*-
/* NaMath.h */
/* $Id$ */
//---------------------------------------------------------------------------
#ifndef NaMathH
#define NaMathH

#include <math.h>

#include <NaGenerl.h>

//---------------------------------------------------------------------------

// PI number (if is not defined)
#ifndef M_PI
#  define M_PI	3.14159265358979323846
#endif /* M_PI */

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
