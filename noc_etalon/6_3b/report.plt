set grid
set logscale
set terminal png
set title "plant3.tf: control & identification error (NN-C and NN-P adoption)"
set output 'errs_trace.png'
plot 'cerr_trace.dat' u 3 w l, 'iderr_trace.dat' u 3 w l
