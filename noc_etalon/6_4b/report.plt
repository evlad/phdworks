set grid
set logscale
set terminal png
set title "Control & identification error (NN-C and NN-P adoption)\nnnc_auf=#1# nnp_auf=#2#"
set output 'errs_trace.png'
plot 'cerr_trace.dat' u 1 w l, 'iderr_trace.dat' u 1 w l
