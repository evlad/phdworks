/* numintegral.cpp */
static char rcsid[] = "$Id: numintegral.cpp,v 1.1 2007-06-20 18:29:57 evlad Exp $";

/*
 *  Numeric integral calculation
 *
 *  based on algorithm from AP library.
 *  See www.alglib.net or alglib.sources.ru for details.
 */

#include <math.h>

#include "numintegral.hpp"


/**
 ***********************************************************************
 * Numberic integrator function as operation over given function in
 * range [a,b] with given precesion epsilon.
 ***********************************************************************/
double
Integral (UnaryFunction& f, double a, double b, double epsilon)
{
  /*
   *  Trapezium method implementation from AP library
   */
  double result;
  int i;
  int n;
  double h;
  double s1;
  double s2;

  n = 1;
  h = b-a;
  s2 = h*(f(a)+f(b))/2;
  do
    {
      s1 = s2;
      s2 = 0;
      i = 1;
      do
        {
	  s2 = s2+f(a-h/2+h*i);
	  i = i+1;
        }
      while(i<=n);
      s2 = s1/2+s2*h/2;
      n = 2*n;
      h = h/2;
    }
  while(fabs(s2-s1)>3*epsilon);
  result = s2;
  return result;
}
