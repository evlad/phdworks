/* mrr.hpp */
/* $Id: mrr.hpp,v 1.2 2008-01-06 21:41:47 evlad Exp $ */
#ifndef __mrr_hpp
#define __mrr_hpp


/**
 ***********************************************************************
 * \file Method of Recurrent Ratio
 ***********************************************************************/


/** phi() recursive calculation.  phi_n(j*delta)*delta is a
    probability that point during n steps are in bounds and at n+1
    step it is in range (j*delta,(j+1)*delta).  k is a number of
    subranges delta in the whole range (see h).  m is a mean average
    of the normal random process with sigma 1. */
double
phi_r (double delta, int n, int j, int k, double m);


/** MRR applied to cummulative sum on changed mean value. */
void
mrr_std_mean (double m_1, double m_x, double h, int k, int n_max);



#endif /* mrr.hpp */
