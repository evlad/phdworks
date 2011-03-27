#!/bin/sh

nnarch=$1
pidtf=$1
dataset=${2:-test}

nnc1=nnc_${nnarch}_1.nn
if [ -f "$nnc1" ] ; then
  echo "Test NN-C in loop: $nnc1"
  root="${dataset}_${nnarch}"
  mode="contr_kind=nnc nncontr=$nnc1 out_u=nnc_u_$root.dat out_e=nnc_e_$root.dat out_ny=nnc_ny_$root.dat"
elif [ -f "$pidtf" ] ; then
  echo "Test PID in loop: $pidtf"
  root="${dataset}"
  mode="contr_kind=lin lincontr_tf=$pidtf out_u=pid_u_$root.dat out_e=pid_e_$root.dat out_ny=pid_ny_$root.dat"
else
  echo "Usage: $0 [nnarch|pid.tf] [learn|test]"
  exit 1
fi

dcsloop.new origsys.par $mode \
  linplant_tf=../model_proof/cstrplant.cof \
  in_r=r_${dataset}.bis in_n=n_${dataset}.bis
