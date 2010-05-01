set grid
set logscale
set title "NN-P offline training based on new NN"
set terminal png
set output 'new_nnp_training.png'
plot 'nnp_trace.dat' u 3 w l, 'nnp_trace.dat' u 6 w l
