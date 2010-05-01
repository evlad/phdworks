set grid
set logscale
set terminal png
set title "Control & identification errors during NN-C training"
set output 'cmp_errs_trace.png'
plot [1:700000] [0.01:100] \
     'cerr_trace.dat' u ($2+1100):1 t "Cmse NN-C training" w l, \
     '../6_4b/cerr_trace.dat' u 2:1 t "Cmse NN-C & NN-P adoption" w l, \
     'iderr_trace.dat' u ($2+1100):1 t "IDmse NN-C training" w l, \
     '../6_4b/iderr_trace.dat' u 2:1 t "IDmse NN-C & NN-P adoption" w l
