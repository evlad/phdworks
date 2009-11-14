set grid
set logscale
set output "nncf_training_eta.png"
set terminal png
set title "NN-C training in control loop depending learning rate"
set xlabel "Time"
plot [1:500000] \
     'cerr_trace5.dat' u 3 t "0.5" w l, \
     'cerr_trace9.dat' u 3 t "0.4" w l, \
     'cerr_trace6.dat' u 3 t "0.3" w l, \
     'cerr_trace10.dat' u 3 t "0.2" w l, \
     'cerr_trace7.dat' u 3 t "0.1" w l, \
     'cerr_trace1.dat' u 3 t "0.05" w l, \
     'cerr_trace2.dat' u 3 t "0.01" w l, \
     0.019 t "Before disorder" w l

#     'cerr_trace5.dat' u 3 t "0.5" w l, \
#     'cerr_trace9.dat' u 3 t "0.4" w l, \
#     'cerr_trace6.dat' u 3 t "0.3" w l, \
#     'cerr_trace10.dat' u 3 t "0.2" w l, \
#     'cerr_trace7.dat' u 3 t "0.1" w l, \
#     'cerr_trace8.dat' u 3 t "0.08" w l, \
#     'cerr_trace1.dat' u 3 t "0.05" w l, \
#     'cerr_trace2.dat' u 3 t "0.01" w l, \
#     'cerr_trace3.dat' u 3 t "0.005" w l, \
#     'cerr_trace4.dat' u 3 t "0.001" w l, \
