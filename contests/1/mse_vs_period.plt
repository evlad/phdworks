set grid
set xlabel "Period, samples"
set ylabel "Control MSE"
plot 'stat_pidbad.dat' u 1):6 t 'PID_{bad}' w l, \
     'stat_pid.dat' u 1:6 t 'PID' w l, \
     'stat_woc.dat' u 1:6 t 'WOC' w l, \
     'stat_nnc.dat' u 1:6 t 'NOC' w l
