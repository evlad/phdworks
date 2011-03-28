#!/bin/sh

# Prepare data for training

# Lengths
trlen=800
evlen=200
totallen=`expr $trlen + $evlen`

if [ ! -s n0.dat ] ; then
  noise_tf=../noise.tf
  drand ${totallen} 0 1 ${noise_tf} >n0.dat
fi

if [ ! -s r0.dat ] ; then
  refer_tf=../refer.tf
  drand ${totallen} 0 1 ${refer_tf} >r0.dat
fi

# Take rest data series
dcsloop dcsloop.par | tail -n 1

# Extract training and evaluation data series
for s in r e u; do
  head -n $trlen ${s}.dat >${s}_tr.dat
  tail -n $evlen ${s}.dat >${s}_ev.dat
done

# Prepare NN and make learning
n=0
for h in "0" "1 5" "1 20" "2 7 5" "2 20 10" "3 7 9 5" "3 15 20 10"; do
#for h in "1 5" ; do
  innfile="ini$n.nnc"
  onnfile="pre$n.nnc"
  tracefile="trace$n.dat"
  nyfile="ny$n.dat"
  echo "$innfile -> $onnfile; hidden layers: $h"
  if MakeNN $innfile Controller 2 1 1 0 0 0 $h >/dev/null 2>&1 ; then
    if [ ! -s $onnfile ] ; then
      echo "Training..."
      time dcontrp dcontrp.par in_nnc_file=$innfile out_nnc_file=$onnfile \
	trace_file=$tracefile | tail -n 7
      echo "Finish!"
    fi
    dcsloop dpidsys.par nncontr=$onnfile out_ny=$nyfile | tail -n 1
  else
    echo "Error!"
  fi
  n=`expr $n + 1`
  echo
done

# End of file
