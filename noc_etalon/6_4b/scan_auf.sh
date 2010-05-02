#!/bin/sh

aufclist="50 100 150 200 300 500 700 1000"
aufplist="50 100 150 200 300 500 700 1000"

for aufc in $aufclist
do
    tee traces/report_c$aufc.plt >/dev/null <<EOF
set grid
set logscale
set terminal png
set title "Control & identification error (NN-C and NN-P adoption)\nnnc_auf=$aufc"
set output 'traces/errs_c$aufc.png'
plot [1:700000] [0.001:100] 1 w d \\
EOF
    for aufp in $aufplist
    do
	[ $aufc = $aufp ] && continue
	echo "`date '+%T'` nnc_auf=$aufc nnp_auf=$aufp"
	dcontrf dcontrf.par nnc_auf=$aufc nnp_auf=$aufp \
	    cerr_trace_file=traces/crms_c${aufc}_p${aufp}.dat \
	    iderr_trace_file=traces/idrms_c${aufc}_p${aufp}.dat \
	    >/dev/null

	tee -a traces/report_c$aufc.plt >/dev/null  <<EOF
, 'traces/crms_c${aufc}_p${aufp}.dat' u 2:1 t "Crms: nnp_auf=$aufp" w l \\
, 'traces/idrms_c${aufc}_p${aufp}.dat' u 2:1 t "IDrms: nnp_auf=$aufp" w l \\
EOF
    done

    gnuplot traces/report_c$aufc.plt
    echo "nnc_auf=$aufc nnp_auf=$aufp done"
done
echo "`date '+%T'` finish"

echo "Making graphs by NNP"
for aufp in $aufplist
do
    tee traces/report_p$aufp.plt >/dev/null  <<EOF
set grid
set logscale
set terminal png
set title "Control & identification error (NN-C and NN-P adoption)\nnnp_auf=$aufp"
set output 'traces/errs_p$aufp.png'
plot [1:700000] [0.001:100] 1 w d \\
EOF
    for aufc in $aufclist
    do
	[ $aufc = $aufp ] && continue
	tee -a traces/report_p$aufp.plt >/dev/null  <<EOF
, 'traces/crms_c${aufc}_p${aufp}.dat' u 2:1 t "Crms: nnc_auf=$aufc" w l \\
, 'traces/idrms_c${aufc}_p${aufp}.dat' u 2:1 t "IDrms: nnc_auf=$aufc" w l \\
EOF
    done

    gnuplot traces/report_p$aufp.plt
    echo "nnp_auf=$aufp nnc_auf=$aufc done"
done
echo "`date '+%T'` finish all"

# End of file
