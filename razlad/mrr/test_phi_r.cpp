/* test_phi_r.cpp */
static char rcsid[] = "$Id: test_phi_r.cpp,v 1.1 2008-01-06 21:42:28 evlad Exp $";

#include <stdio.h>
#include <stdlib.h>

#include "mrr.hpp"

int
main (int argc, char* argv[])
{
  if(argc != 6)
    {
      fprintf(stderr, "syntax: %s delta n j k m\n", argv[0]);
      return 1;
    }

  double	delta = atof(argv[1]);
  int		n = atoi(argv[2]);
  int		j = atoi(argv[3]);
  int		k = atoi(argv[4]);
  double	m = atof(argv[5]);

  double	phi = phi_r(delta, n, j, k, m);

  printf("phi(delta=%g, n=%d, j=%d, k=%d, m=%g) = %g\n",
	 delta, n, j, k, m, phi);

  return 0;
}
