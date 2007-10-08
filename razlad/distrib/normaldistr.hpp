/* normaldistr.hpp */
/* $Id: normaldistr.hpp,v 1.3 2007-10-08 20:22:28 evlad Exp $ */
#ifndef __normaldistr_hpp
#define __normaldistr_hpp

#include "../integrator/numintegral.hpp"


/**
 ***********************************************************************
 * Class for normal (Gauss) probability density calculation.
 ***********************************************************************/
class NormalDensity : public UnaryFunction
{
public:

  /** Calculate the function "as is" */
  static double	f (double x, double mx, double sx);

  /** Construct the function with fixed average (mx) and standard
      deviation (sx). */
  NormalDensity (double mx = 0.0, double sx = 1.0);

  /** Calculate function value for given argument. */
  virtual double	operator() (double a);

public:/* data */

  double	m_fMean;	/**< mx */
  double	m_fStdDev;	/**< sx */

};


/** Probability density function calculation: f(x). */
double	pdf (double x, double mx = 0.0, double sx = 1.0);

/** Cummulative distribution function calculation: F(x)=int f(x) */
double	cdf (double x, double mx = 0.0, double sx = 1.0, double prec = 1e-6);

/** Cummulative distribution function calculation (Hill, AS66):
    F(x)=int f(x) */
double	cdf_as66 (double x, double mx = 0.0, double sx = 1.0);

/** Error function: e(x)=2 * int_0^x(exp(-t**2)dt)/sqrt(PI) */
double	erf (double x, double prec = 1e-6);

/** Error function.  Fast and draft approximation. */
double	erf_a (double x);

/** Conjugate error function: e~(x)=1 - e(x) */
double	erfc (double x, double prec = 1e-6);

/** Factorial calculation: fact(n) = n! = 1*2*3*...*(n-1)*n */
double	fact (int n);

/** AS66 implementation */
double	alnorm  (double x, int upper = 0);



#endif /* normaldistr.hpp */
