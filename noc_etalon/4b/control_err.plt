reset
set grid
set title "Disorder influence to NN control at t=500"
set output "control_err.png"
set terminal png
set xlabel "Time"
plot [450:550] 'r_out.dat' t 'Reference' w l, 'ny.dat' t 'Plant observation' w l
