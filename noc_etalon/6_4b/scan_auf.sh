#!/bin/sh

#for aufc in 50 200 1000 3000 5000
for aufc in 4000 #5000 6000 7000
do
#    for aufp in 50 100 200 500 1000
    for aufp in 30 #40 50 60
    do
	[ $aufc = $aufp ] && continue
	echo "`date '+%T'` nnc_auf=$aufc nnp_auf=$aufp"
	dcontrf dcontrf.par max_epochs=0 nnc_auf=$aufc nnp_auf=$aufp >/dev/null

	sed "s/#1#/$aufc/g" report.plt | sed "s/#2#/$aufp/g" >report_cur.plt
	gnuplot report_cur.plt
	mv errs_trace.png errs_trace_auf_c${aufc}_p${aufp}.png
	mv cerr_trace.dat cerr_trace_auf_c${aufc}_p${aufp}.dat
	mv iderr_trace.dat iderr_trace_auf_c${aufc}_p${aufp}.dat
    done
done
echo "`date '+%T'` finish"

# End of file
