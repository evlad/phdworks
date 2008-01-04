/* mrr.hpp */
/* $Id: mrr.hpp,v 1.1 2008-01-04 19:42:43 evlad Exp $ */
#ifndef __mrr_hpp
#define __mrr_hpp


/**
 ***********************************************************************
 * \file Method of Recurrent Ratio
 ***********************************************************************/


/** MRR applied to cummulative sum on changed mean value. */
void
mrr_std_mean (double m_1, double m_x, double h, int k, int n_max);



#endif /* mrr.hpp */
