//-*-C++-*-
/* nosense.h */
/* $Id: nosense.h,v 1.2 2003-01-06 10:15:14 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef __nosense_h
#define __nosense_h

#include <NaExFunc.h>


//---------------------------------------------------------------------------
// Class for external function which implements no-sensitive area
//            ^
//            |      /
//            |     /
//            |    / Gain
// -------=========-------->
//       /    |
//      /     |<-->
//     /      | HalfWidth
//
class NaNoSenseAreaFunc : public NaExternFunc
{
public:

  // Make empty (y=x) function
  NaNoSenseAreaFunc ();

  // Make function with given options and initial vector
  // options: HalfWidth Gain
  //          HalfWidth - floating point number
  //          Gain      - floating point number
  // initial: -
  NaNoSenseAreaFunc (char* szOptions, NaVector& vInit);

  // Destructor
  virtual ~NaNoSenseAreaFunc ();

  // Reset operations, that must be done before new modelling
  // session will start.  It's guaranteed that this reset will be
  // called just after Timer().ResetTime().
  virtual void	Reset ();

  // ATTENTION!  It's guaranteed that this->Function() will be called
  // only once for each time step.  Index of the time step and current
  // time can be got from Timer().

  // Compute output on the basis of internal parameters,
  // stored state and external input: y=F(x,t,p)
  virtual void	Function (NaReal* x, NaReal* y);

protected:

  NaReal	fHalfWidth;	// half width of no-sensitive area
  NaReal	fGain;		// gain coefficient y=k*x
};


//---------------------------------------------------------------------------
#endif // __nosense_h
