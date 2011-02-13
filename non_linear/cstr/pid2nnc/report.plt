set title "Training of NNC equal to original PID"
set logscale
set grid
set xlabel "Time, epoch"
set ylabel "MSE"
set terminal png
set output 'pid2nnc_training.png'
plot [1:5000] \
     'nnc_er_trace.dat' u 3 t "Learning set error" w l, \
     'nnc_er_trace.dat' u 6 t "Test set error" w l
#pause -1
reset
set title "NNC output comparing with original PID (learning set)"
set grid
set xlabel "Time, min"
set ylabel "Coolant flow, m3/min"
set terminal png
set output 'pid2nnc_learn_set.png'
plot 'u_learn.dat' t "PID control" w l, \
     'nn_u_learn.dat' t "NNC control" w l
#pause -1
reset
set title "NNC output comparing with original PID (test set)"
set grid
set xlabel "Time, min"
set ylabel "Coolant flow, m3/min"
set terminal png
set output 'pid2nnc_test_set.png'
plot 'u_test.dat' t "PID control" w l, \
     'nn_u_test.dat' t "NNC control" w l
#pause -1
reset
set title "NNC and PID control over CSTR (learning set)"
set grid
set xlabel "Time, min"
set ylabel "Reactor temperature, K"
set terminal png
set output 'pid_vs_nnc_learn_set.png'
plot [0:2000] [352:370] \
     'r_learn.dat' t "Reference" w l, \
     'ny_learn.dat' t "PID controlled" w l, \
     'nn_ny_learn.dat' t "NNC controlled" w l
#pause -1
reset
set title "NNC and PID control over CSTR (test set)"
set grid
set xlabel "Time, min"
set ylabel "Reactor temperature, K"
set terminal png
set output 'pid_vs_nnc_test_set.png'
plot [0:1000] [352:370] \
     'r_test.dat' t "Reference" w l, \
     'ny_test.dat' t "PID controlled" w l, \
     'nn_ny_test.dat' t "NNC controlled" w l
