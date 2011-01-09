#!/bin/sh

# Prepare r x e 2D distribution of training data to correlate it with
# result.

for d in stoch step harm ; do
  echo "Processing $d ..."
  Distr2D ${d}/e.dat ${d}/r.dat ${d}_re2d.txt ${d}_re2d.dat <<EOF
-2
2.5
8
-3
3.5
12
EOF
  sed "s/FILENAME/${d}_re2d/g" re2d_template.plt >${d}_re2d.plt
  gnuplot ${d}_re2d.plt >/dev/null
  rm -f ${d}_re2d.eps
  ps2eps ${d}_re2d.ps
done

# End of file
