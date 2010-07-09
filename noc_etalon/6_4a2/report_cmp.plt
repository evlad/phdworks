set grid
set terminal png
set title "Plant change at time=2000: control and identification MSE"
set xlabel "Time, samples"
set ylabel "MSE"
set logscale
set title "Unsteady plant conditions: control & identification MSE during adoption"
set output 'cmp_errs_4a_4b_logscale.png'
plot [1:700000] [0.01:100] \
     'cerr_trace.dat' u ($2+1100):1 t "Control while NN-C adoption" w l, \
     '../6_4b/cerr_trace.dat' u 2:1 t "Control while NN-C & NN-P adoption" w l, \
     'iderr_trace.dat' u ($2+1100):1 t "Identification while NN-C adoption" w l, \
     '../6_4b/iderr_trace.dat' u 2:1 t "Identification while NN-C & NN-P adoption" w l, \
     'plant_change.dat' t "Plant change" w l, \
     'NNC_adopt_start.dat' t "NN-C adoption start" w l
unset logscale
set output 'cmp_errs_4a_4b_600K.png'
plot [0:600000] [0:4] \
     'cerr_trace.dat' u ($2+1100):1 t "Control while NN-C adoption" w l, \
     '../6_4b/cerr_trace.dat' u 2:1 t "Control while NN-C & NN-P adoption" w l, \
     'iderr_trace.dat' u ($2+1100):1 t "Identification while NN-C adoption" w l, \
     '../6_4b/iderr_trace.dat' u 2:1 t "Identification while NN-C & NN-P adoption" w l
set output 'cmp_errs_4a_4b_20K.png'
plot [0:20000] [0:4] \
     'cerr_trace.dat' u ($2+1100):1 t "Control while NN-C adoption" w l, \
     '../6_4b/cerr_trace.dat' u 2:1 t "Control while NN-C & NN-P adoption" w l, \
     'iderr_trace.dat' u ($2+1100):1 t "Identification while NN-C adoption" w l, \
     '../6_4b/iderr_trace.dat' u 2:1 t "Identification while NN-C & NN-P adoption" w l, \
     'plant_change.dat' t "Plant change" w l, \
     'NNC_adopt_start.dat' t "NN-C adoption start" w l
