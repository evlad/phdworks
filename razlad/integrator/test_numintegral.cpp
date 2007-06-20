/* test_numintegral.cpp */
static char rcsid[] = "$Id: test_numintegral.cpp,v 1.1 2007-06-20 18:29:57 evlad Exp $";

#include <stdio.h>

#include "numintegral.hpp"



/** y=x**2 */
class Square : public UnaryFunction
{
public:

  virtual double	operator () (double arg) {
    return arg * arg;
  }
}	square_f;



/* Test case 1:
   $ ./test_numintegral
   S_0^1(x**2)=0.333374
 */
main ()
{
  double	s;

  s = Integral(square_f, 0.0, 1.0, 0.0001);

  printf("S_0^1(x**2)=%g\n", s);

  return 0;
}
