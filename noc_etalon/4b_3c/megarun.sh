#!/bin/sh

#i=1
#for auf in 10 30 50 70 90 110 130 150
i=9
for auf in 1 2 5
do
    echo "===== $i ======"
    dcontrf dcontrf.par \
	nnc_auf=${auf} \
	eta=0.3 \
	eta_output=0.0005 \
	cerr_trace_file=cerr_trace$i.dat \
	iderr_trace_file=iderr_trace$i.dat >log$i.txt
    mv dcontrf.log dcontrf$i.log
    i=`expr $i + 1`
done

#gnuplot report.plt
