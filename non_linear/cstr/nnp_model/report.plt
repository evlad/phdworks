set title "Training of NNP to predict CSTR plant"
set logscale
set grid
set xlabel "Time, epoch"
set ylabel "MSE"
set terminal png
set output 'nnp_training.png'
plot [1:5000] \
     'nnp_2+2_trace.dat' u 3 t "Learning set error" w l, \
     'nnp_2+2_trace.dat' u 6 t "Test set error" w l
#pause -1
reset
set title "NNP prediction comparing with CSTR output (learning set)"
set grid
set xlabel "Time, min"
set ylabel "Temperature, K"
set terminal png
set output 'nnp_learn_set.png'
plot [0:2000] [352:370] \
     '../ny_learn.dat' t "Plant output" w l, \
     'nn_y_learn.dat' t "NNP prediction" w l
#pause -1
reset
set title "NNP prediction comparing with CSTR output (test set)"
set grid
set xlabel "Time, min"
set ylabel "Temperature, K"
set terminal png
set output 'nnp_test_set.png'
plot [0:1000] [352:370] \
     '../ny_test.dat' t "Plant output" w l, \
     'nn_y_test.dat' t "NNP prediction" w l
#pause -1
