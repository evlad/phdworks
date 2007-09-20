/* erfc.cpp */
static char rcsid[] = "$Id: erfc.cpp,v 1.1 2007-09-20 20:03:37 evlad Exp $";

#include <stdio.h>
#include <stdlib.h>

#include "normaldistr.hpp"


/** Syntax:
    erfc Value [Precision]
*/
int
main (int argc, char* argv[])
{
  if(argc < 2 || argc > 3)
    {
      fprintf(stderr, "Syntax: %s Value [Precision]\n",
	      argv[0]);
      return 1;
    }

  double	fValue = atof(argv[1]);
  double	fPrec = argc == 3? atof(argv[2]): 1e-6;

  double	fErrorFuncC = erfc(fValue, fPrec);
  printf("%g\t%g\n", fValue, fErrorFuncC);
 
  return 0;
}
