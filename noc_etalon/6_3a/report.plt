#!DSUB_DELAY=-1 dsub r.dat ny.dat >e-1.dat
#!sed 's/-//g' e-1.dat >cerr.dat
set grid
set terminal png
set title "Original plant conditions: control MSE"
set xlabel "Time, samples"
set ylabel "MSE"
set logscale
set output 'cmp_cerr_3a_3b_logscale.png'
plot 'cerr_trace.dat' u 1 t "NN-C without adoption" w l, \
     '../6_3b/cerr.dat' u 1 t "NN-C and NN-P adoption" w l, \
     '../6_3b/iderr.dat' u 1 t "Identification while adoption" w l
unset logscale
set output 'cmp_cerr_3a_3b_2M.png'
plot [0:2000000] [0:1.2] \
     'cerr_trace.dat' u 1 t "NN-C without adoption" w l, \
     '../6_3b/cerr.dat' u 1 t "NN-C and NN-P adoption" w l, \
     '../6_3b/iderr.dat' u 1 t "Identification while adoption" w l
