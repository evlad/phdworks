#!/bin/sh

nnarch=$1

nnc0=nnc_${nnarch}_0.nn
nnc1=nnc_${nnarch}_1.nn
if [ ! -f $nnc0 ] ; then
  echo "Neural network file $nnc0 is not found!"
  exit 1
fi

echo "Teach NN-C: $nnc0 -> $nnc1"

dcontrp.new pid2nnc.par in_nnc_file=$nnc0 out_nnc_file=$nnc1 \
  trace_file=nnc_${nnarch}_trace.dat \
  nn_u=nn_u_learn_${nnarch}.dat test_nn_u=nn_u_test_${nnarch}.dat

# End of file
