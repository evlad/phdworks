reset
set grid
set title "Disorder influence to NN identification during NN control at t=500"
set output "id_err.png"
set terminal png
set xlabel "Time"
plot [450:550] 'ny.dat' t 'Plant+Noise' w l, 'nn_y.dat' t 'NN-P output' w l, 'nn_e.dat' t 'Identif.error' w l
