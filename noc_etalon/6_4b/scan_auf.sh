#!/bin/sh

for aufc in 50 200 1000 5000
do
    for aufp in 50 200 1000 5000
    do
	[ $aufc = $aufp ] && continue
	echo "`date '+%T'` nnc_auf=$aufc nnp_auf=$aufp"
	dcontrf dcontrf.par nnc_auf=$aufc nnp_auf=$aufp >/dev/null

	gnuplot report.plt
	mv errs_trace.png errs_trace_auf_c${aufc}_p${aufp}.png
	mv cerr_trace.dat cerr_trace_auf_c${aufc}_p${aufp}.dat
	mv iderr_trace.dat iderr_trace_auf_c${aufc}_p${aufp}.dat
    done
done

# End of file
