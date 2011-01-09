#!/bin/sh

# Lengths
trlen=800
evlen=200
totallen=`expr $trlen + $evlen`

if [ ! -s n0.dat ] ; then
  noise_tf=../../noise.tf
  drand ${totallen} 0 1 ${noise_tf} >n0.dat
fi

if [ ! -s r0.dat ] ; then
  refer_tf=../../refer.tf
  drand ${totallen} 0 1 ${refer_tf} >r0.dat
fi

# Take rest data series
dcsloop dcsloop.par 

# Extract training and evaluation data series
for s in r e u; do
  head -n $trlen ${s}.dat >${s}_tr.dat
  tail -n $evlen ${s}.dat >${s}_ev.dat
done

dcontrp dcontrp.par

# End of file
