set grid
set logscale
set output "nncf_training_auf.png"
set terminal png
set title "NN-C training in control loop depending auto-update frequency"
set xlabel "Time"
plot [1:500000] \
     'cerr_trace9.dat' u 3  t "1" w l, \
     'cerr_trace10.dat' u 3 t "2" w l, \
     'cerr_trace11.dat' u 3 t "5" w l, \
     'cerr_trace1.dat' u 3 t "10" w l, \
     'cerr_trace2.dat' u 3 t "30" w l, \
     'cerr_trace4.dat' u 3 t "70" w l, \
     'cerr_trace8.dat' u 3 t "150" w l, \
     0.019 t "Before disorder" w l

#     'cerr_trace3.dat' u 3 t "50" w l, \
#     'cerr_trace5.dat' u 3 t "90" w l, \
#     'cerr_trace6.dat' u 3 t "110" w l, \
#     'cerr_trace7.dat' u 3 t "130" w l, \
