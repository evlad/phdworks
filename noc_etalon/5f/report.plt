set grid
set logscale
set terminal png
set title "plant3_notst.cof: control error"
set output 'cerr_trace.png'
plot 'cerr_trace.dat' u 3 w l
set title "plant3_notst.cof: identification error"
set output 'iderr_trace.png'
plot 'iderr_trace.dat' u 3 w l
