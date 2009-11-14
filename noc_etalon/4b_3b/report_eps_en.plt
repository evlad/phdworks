set grid
set logscale
set output "nncf_training_eta_en.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "NN-C training in control loop depending learning rate"
set xlabel "Time"
set ylabel "Control error"
plot [1:500000] \
     'cerr_traces_eta.tsv' u 1 t "0.5" w l, \
     'cerr_traces_eta.tsv' u 2 t "0.4" w l, \
     'cerr_traces_eta.tsv' u 3 t "0.3" w l, \
     'cerr_traces_eta.tsv' u 4 t "0.2" w l, \
     'cerr_traces_eta.tsv' u 5 t "0.1" w l, \
     'cerr_traces_eta.tsv' u 6 t "0.05" w l, \
     'cerr_traces_eta.tsv' u 7 t "0.01" w l, \
     0.019 t "Before disorder" w l
