set grid
set title "Sliding base statistics"
set xlabel "Time"
set ylabel "Error"

set logscale y
plot [0:2000000] \
     'e_10k.dat' u 3:1 t 'Ctrl.error RMS' w l, \
     'id_e_10k.dat' u 3:1 t 'Id.error RMS' w l
pause -1

unset logscale y
plot [0:2000000] \
     'e_10k.dat' u 3:2 t 'Ctrl.error std.dev.' w l, \
     'id_e_10k.dat' u 3:2 t 'Id.error std.dev.' w l
pause -1
