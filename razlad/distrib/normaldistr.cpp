/* normaldistr.cpp */
static char rcsid[] = "$Id: normaldistr.cpp,v 1.1 2007-07-24 20:05:33 evlad Exp $";

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
