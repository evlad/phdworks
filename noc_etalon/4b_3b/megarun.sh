#!/bin/sh

#i=1
#for eta_base in 0.05 0.01 0.005 0.001
#i=5
#for eta_base in 0.5 0.3 0.1 0.08
i=9
for eta_base in 0.4 0.2
do
    echo "===== $i ======"
    dcontrf dcontrf.par \
	nnc_auf=50 \
	eta=${eta_base} \
	eta_output=0.0005 \
	cerr_trace_file=cerr_trace$i.dat \
	iderr_trace_file=iderr_trace$i.dat >log$i.txt
    mv dcontrf.log dcontrf$i.log
    i=`expr $i + 1`
done
