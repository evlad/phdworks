/* normaldistr.cpp */
static char rcsid[] = "$Id: normaldistr.cpp,v 1.3 2007-09-20 18:02:48 evlad Exp $";

#include <math.h>
#include <stdio.h>

#include "normaldistr.hpp"


/**
 ***********************************************************************
 * Calculate the function "as is".
 ***********************************************************************/
double
NormalDensity::f (double x, double mx, double sx)
{
  double	inv_sx = 1 /sx;
  double	xmx2 = (x - mx) * (x - mx);
  return exp(- 0.5 * xmx2 * inv_sx * inv_sx) * inv_sx / sqrt(2 * M_PI);
}


/**
 ***********************************************************************
 * Construct the function with fixed average (mx) and standard
 * deviation (sx).
 ***********************************************************************/
NormalDensity::NormalDensity (double mx, double sx)
  : m_fMean(mx), m_fStdDev(sx)
{
  if(m_fStdDev <= 0.0)
    {
      fprintf(stderr,
	      "NormalDensity() error: wrong standard deviation: %g\n",
	      m_fStdDev);
      m_fStdDev = 1.0;
    }
}


/**
 ***********************************************************************
 * Calculate function value for given argument.
 ***********************************************************************/
double
NormalDensity::operator() (double a)
{
  return f(a, m_fMean, m_fStdDev);
}


/**
 ***********************************************************************
 * Probability density function calculation.
 ***********************************************************************/
double
pdf (double x, double mx, double sx)
{
  return NormalDensity::f(x, mx, sx);
}


/**
 ***********************************************************************
 * Cummulative distribution function calculation: F(x)=int f(x)
 ***********************************************************************/
double
cdf (double x, double mx, double sx, double prec)
{
  return 0.5 * (1 + erf(M_SQRT1_2 * (x - mx) / sx, prec));
}


/**
 ***********************************************************************
 * Error function: e(x)=2 * int_0^x(exp(-t**2)dt)/sqrt(PI)
 ***********************************************************************/
double
erf (double x, double prec)
{
  if(prec <= 0.0)
    return erf_a(x);
  return 1 - erfc(x, prec);
}


/**
 ***********************************************************************
 * Error function.  Fast and draft approximation.
 ***********************************************************************/
double
erf_a (double x)
{
  double	a = -8 * (M_PI - 3) / (3 * M_PI * (M_PI - 4));
  return	sqrt(1 - exp(- x * x * (M_2_SQRTPI * M_2_SQRTPI + a * x * x)
			     / (1 + a * x * x)));
}


/**
 ***********************************************************************
 * Conjugate error function: e~(x) = 1 - e(x)
 ***********************************************************************/
double
erfc (double x, double prec)
{
  double	k = M_2_SQRTPI * 0.5 * exp(- x * x) / x;
  double	new_f = k, prev_f;
  int		n = 0;

  do{
    ++n;
    prev_f = new_f;

    new_f = k * fact(2 * n) / (fact(n) * pow(2 * x, 2 * n));

    if(n % 2 == 1)
      new_f = prev_f - new_f;
    else
      new_f = prev_f + new_f;

  } while(fabs(prev_f - new_f) >= prec);

  return new_f;
}


/**
 ***********************************************************************
 * Factorial calculation: fact(n) = n! = 1*2*3*...*(n-1)*n
 ***********************************************************************/
double
fact (int n)
{
  if(n < 0)
    return 0.0;
  if(n == 0)
    return 1.0;

  double	f = n;
  for(int i = n - 1; i > 1; --i)
    f *= i;

  return f;
}
