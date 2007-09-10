/* cdf.cpp */
static char rcsid[] = "$Id: cdf.cpp,v 1.1 2007-09-10 21:13:23 evlad Exp $";

#include <stdio.h>
#include <stdlib.h>

#include "normaldistr.hpp"


/** Syntax:
    cdf LowBound HighBound Step [Precision]
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
  double	fPrec = argc == 5? atof(argv[4]): 1e-6;

  for(double x = fLowB; x < fHighB; x += fStep)
    printf("%g\t%g\n", x, cdf(x));
 
  return 0;
}
