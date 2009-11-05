set grid
set logscale
set output "nnc_training.png"
set terminal png
set title "NN-C training in control loop after NN-P adoption"
set xlabel "Time"
plot [1:500000] 'cerr_trace.dat' u 3 t "Control MSE" w l, \
     0.019 t "Before disorder" w l, 0.165 t "Before training" w l
