/* erf.cpp */
static char rcsid[] = "$Id: erf.cpp,v 1.1 2007-10-08 20:24:25 evlad Exp $";

#include <stdio.h>
#include <stdlib.h>

#include "normaldistr.hpp"


/** Syntax:
    erf LowBound HighBound Step [Precision]
*/
int
main (int argc, char* argv[])
{
  if(argc < 4 || argc > 5)
    {
      fprintf(stderr, "Syntax: %s LowBound HighBound Step [Precision]\n",
	      argv[0]);
      return 1;
    }

  double	fLowB = atof(argv[1]);
  double	fHighB = atof(argv[2]);
  double	fStep = atof(argv[3]);
  double	fPrec = argc == 5? atof(argv[4]): -1.0;

  for(double x = fLowB; x < fHighB; x += fStep)
    printf("%g\t%g\n", x, erf(x, fPrec));
 
  return 0;
}
