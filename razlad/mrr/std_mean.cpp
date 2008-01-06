/* std_mean.cpp */
static char rcsid[] = "$Id: std_mean.cpp,v 1.2 2008-01-06 21:41:31 evlad Exp $";

#include <map>
#include <vector>

#include "../distrib/normaldistr.hpp"
#include "mrr.hpp"


/**
 ***********************************************************************
 * Implementation of method of recurrent ratios for analysis of
 * algorithm of cummulative sums.
 ***********************************************************************/


/** PDF */
double
w_x (double x, double m)
{
  double	r = pdf(x, m);
  //printf("w_x(%g, %g)=%g\n", x, m, r);
  return r;
}


/** CDF */
double
W_x (double x, double m)
{
  double	r = cdf_as66(x, m);
  //printf("W_x(%g, %g)=%g\n", x, m, r);
  return r;
}


/** phi() recursive calculation.  phi_n(j*delta)*delta is a
    probability that point during n steps is in bounds and at n+1 step
    it is in range (j*delta,(j+1)*delta).  k is a number of subranges
    delta in the whole range (see h).  m is a mean average of the
    normal random process with sigma 1. */
double
phi_r (double delta, int n, int j, int k, double m)
{
  typedef std::pair<int,int>			phi_params;
  typedef std::map<phi_params, double>	phi_cache;
  static phi_cache	s_cache;

  phi_params	cur_params(n, j);
  phi_cache::iterator	it = s_cache.find(cur_params);
  if(s_cache.end() != it)
    /* found cached value */
    return it->second;

  if(n == 1)
    {
      double	phi = w_x(j * delta, m);
      s_cache[cur_params] = phi;
      return phi;
    }

  double s1 = phi_r(delta, n - 1, 0, k, m) * w_x(j * delta, m) * 0.5;
  double s3 = phi_r(delta, n - 1, k, k, m) * w_x((j - k) * delta, m) * 0.5;
  double s2 = 0.0;
  for(int i = 1; i < k; ++i)
    {
      s2 += phi_r(delta, n - 1, i, k, m) * w_x((j - i) * delta, m);
    }

  double	phi = delta * (s1 + s2 + s3);
  s_cache[cur_params] = phi;

  return phi;
}


/** q() recursive calculation */
double
q_r (double delta, int n, int k, double m)
{
  if(n == 1)
    {
      return W_x(0, m);
    }

  double s1 = phi_r(delta, n - 1, 0, k, m) * W_x(0, m) * 0.5;
  double s3 = phi_r(delta, n - 1, k, k, m) * W_x( - k * delta, m) * 0.5;
  double s2 = 0.0;
  for(int i = 1; i < k; ++i)
    {
      s2 += phi_r(delta, n - 1, i, k, m) * W_x( - i * delta, m);
    }

  return delta * (s1 + s2 + s3);
}


/** p() recursive calculation */
double
p_r (double delta, int n, int k, double m)
{
  if(n == 1)
    {
      return 1 - W_x(k * delta, m);	//!!!
    }

  double s1 = phi_r(delta, n - 1, 0, k, m) * (1 - W_x(k, m)) * 0.5;
  double s3 = phi_r(delta, n - 1, k, k, m) * (1 - W_x(0, m)) * 0.5;
  double s2 = 0.0;
  for(int i = 1; i < k; ++i)
    {
      s2 += phi_r(delta, n - 1, i, k, m) * (1 - W_x((k - i) * delta, m));//!!!
    }

  return delta * (s1 + s2 + s3);
}


/**
 ***********************************************************************
 * MRR applied to cummulative sum on changed mean value.
 ***********************************************************************/
void
mrr_std_mean (double m_1, double m_x, double h, int k, int n_max)
{
  /* 3 */
  double	m = m_x - m_1/2;
  double	delta = h / k;

  /* 4 */
  //double	phi_1_j = w_x(j * delta, m);
  double	qt_1 = W_x(0, m);
  double	pt_1 = 1 - W_x(k * delta, m);

  /* 5 */
  double	P_d = pt_1;
  double	P_c = qt_1;
  double	Sigma_p = 1 * pt_1;
  double	Sigma_q = 1 * qt_1;

  /* 6 */
  int	n = 1;
  for(n = 1; n <= n_max; ++n)
    {
      /* 7 */
      //double	phi_np1_j = ???;
      double	pt_np1 = p_r(delta, n + 1, k, m);
      double	qt_np1 = q_r(delta, n + 1, k, m);
      //printf("pt_np1=%g\tqt_np1=%g\n", pt_np1, qt_np1);

      /* 8 */
      //double	Sigma_pa = ???;
      //double	Sigma_qa = ???;
      //double	P_da = ???;

      /* 9 */
      Sigma_p += (n + 1) * pt_np1;
      Sigma_q += (n + 1) * qt_np1;

      /* 10 */
      P_d += pt_np1;
      P_c += qt_np1;

      /* 11 */
      //n++;

      /* 12 */
      double	tau_mean = (Sigma_p + Sigma_q) / P_d;
      double	tau_a = 0.0;//(Sigma_pa + Sigma_qa) / P_da;

      /* 13 */
      double	P = P_d + P_c;

      /* 14 */
      //printf("n=%d\ttau_mean=%g\ttau_a=%g\tP=%g\n", n, tau_mean, tau_a, P);
      printf("%d\t%g\n", n, tau_mean);

      /* 15 */
    }//while(n < n_max);

  /* 16 */
  std::vector<double>	p(n);
  for(int i = 0; i < n; ++i)
    {
      if(i == 0)
	{
	  p[0] = pt_1;
	}
      else if(i == 1)
	{
	  p[1] = p_r(delta, i + 1, k, m)
	    + q_r(delta, 1, k, m) * p[i-1];
	}
      /* else if(i == 2)
	{
	  p[2] = p_r(delta, i + 1, k, m)
	    + q_r(delta, 1, k, m) * p[i-1] + q_r(delta, i, k, m) * p[i-2];
        }*/
      else
	{
	  p[i] = p_r(delta, i + 1, k, m);
	  for(int j = 1; j <= i-1; ++j)
	    p[i] += q_r(delta, j, k, m) * p[i-1-j+1];
	}
    }

  /* 17 */
  double	CSum = 0.0;
  for(int i = 0; i < n; ++i)
    CSum += p[i];

#if 0
  /* 18 */
  printf("CSum(P)=%g\n", CSum);
  for(int i = 0; i < n; ++i)
    printf("%d\t%g\n", i+1, p[i]);
#endif
}
