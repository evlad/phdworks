//---------------------------------------------------------------------------

#include <math.h>
#include <time.h>
#include <stdlib.h>

#include "NaMath.h"
#include "NaLogFil.h"


//---------------------------------------------------------------------------

//////////////////////////////
// Random number generation //
//////////////////////////////

//---------------------------------------------------------------------------
// Setup random generator from the system timer
extern "C" void
reset_rand ()
{
    time_t	tTime = time(NULL);
    srand(tTime);
}


//---------------------------------------------------------------------------
// Unified destributed random number
extern "C" NaReal
rand_unified (NaReal fMin, NaReal fMax)
{
    NaReal v = fMin + (fMax - fMin) * rand() / (NaReal)RAND_MAX;
    return v;
}


//---------------------------------------------------------------------------
// Gaussian normal random number distribution
// Marsaglia-Bray algorithm
extern "C" NaReal
rand_gaussian (NaReal fMean, NaReal fStdDev)
{
    NaReal  u1, u2, s2;

    do{
        u1 = rand_unified(-1, 1);
        u2 = rand_unified(-1, 1);
        s2 = u1 * u1 + u2 * u2;
    }while(s2 >= 1);

    return sqrt(-2 * log(s2)/s2) * u1 * fStdDev + fMean;
}


/*
function RandG(Mean, StdDev: Extended): Extended;
{ Marsaglia-Bray algorithm }
var
  U1, S2: Extended;
begin
  repeat
    U1 := 2*Random - 1;
    S2 := Sqr(U1) + Sqr(2*Random-1);
  until S2 < 1;
  Result := Sqrt(-2*Ln(S2)/S2) * U1 * StdDev + Mean;
end;
*/


//---------------------------------------------------------------------------
#pragma package(smart_init)
 
