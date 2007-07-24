/* normaldistr.hpp */
/* $Id: normaldistr.hpp,v 1.1 2007-07-24 20:05:33 evlad Exp $ */
#ifndef __normaldistr_hpp
#define __normaldistr_hpp

#include "numintegral.hpp"


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


#endif /* normaldistr.hpp */
