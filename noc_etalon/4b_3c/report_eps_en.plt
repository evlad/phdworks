set grid
set logscale
set output "nncf_training_auf_en.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "NN-C training in control loop depending auto-update frequency"
set xlabel "Time"
set ylabel "Control error"
plot [1:500000] \
     'cerr_traces_auf.tsv' u 1  t "1" w l, \
     'cerr_traces_auf.tsv' u 2 t "2" w l, \
     'cerr_traces_auf.tsv' u 3 t "5" w l, \
     'cerr_traces_auf.tsv' u 4 t "10" w l, \
     'cerr_traces_auf.tsv' u 5 t "30" w l, \
     'cerr_traces_auf.tsv' u 6 t "70" w l, \
     'cerr_traces_auf.tsv' u 7 t "150" w l, \
     0.019 t "Before disorder" w l
