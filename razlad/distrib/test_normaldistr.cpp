/* test_normaldistr.cpp */
static char rcsid[] = "$Id: test_normaldistr.cpp,v 1.1 2007-09-10 21:13:23 evlad Exp $";

#include <stdio.h>

#include "normaldistr.hpp"



/* Test case 1:
   $ ./test_numintegral
   S_0^1(x**2)=0.333374
 */
main ()
{
  printf("*** Test for factorial:\n");
  for(int i = 0; i < 10; ++i)
    printf("  %d! = %g\n", i, fact(i));

  printf("*** Test for PDF(x):\n");
  for(double x = -4.0; x <= 4.0; x += 0.2)
    printf("  pdf(%g) =\t%g\n", x, pdf(x));

  return 0;
}
