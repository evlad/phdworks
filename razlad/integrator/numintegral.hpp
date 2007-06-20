/* numintegral.hpp */
/* $Id: numintegral.hpp,v 1.1 2007-06-20 18:29:57 evlad Exp $ */
#ifndef __numintegral_hpp
#define __numintegral_hpp


/*
 *  Numeric integral calculation
 *
 *  based on algorithm from AP library.
 *  See www.alglib.net or alglib.sources.ru for details.
 */

/**
 ***********************************************************************
 * Unary function abstract object.
 ***********************************************************************/
class UnaryFunction
{
public:

  /** Calculate function value for given argument. */
  virtual double	operator() (double a) = 0;

};


/**
 ***********************************************************************
 * Numberic integrator function as operation over given function in
 * range [a,b] with given precesion epsilon.
 ***********************************************************************/
double	Integral (UnaryFunction& f, double a, double b, double epsilon);


#endif /* numintegral.hpp */
