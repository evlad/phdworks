/* test_std_mean.cpp */
static char rcsid[] = "$Id: test_std_mean.cpp,v 1.1 2008-01-04 19:42:43 evlad Exp $";

#include <stdio.h>
#include <stdlib.h>

#include "mrr.hpp"

int
main (int argc, char* argv[])
{
  if(argc != 6)
    {
      fprintf(stderr, "syntax: %s m_1 m_x h k n_max\n", argv[0]);
      return 1;
    }

  double	m_1 = atof(argv[1]);
  double	m_x = atof(argv[2]);
  double	h = atof(argv[3]);
  int		k = atoi(argv[4]);
  int		n_max = atoi(argv[5]);

  mrr_std_mean(m_1, m_x, h, k, n_max);

  return 0;
}
