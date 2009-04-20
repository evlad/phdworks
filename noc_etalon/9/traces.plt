set grid
plot 'cerr_trace.dat' u 3 w l, 'iderr_trace.dat' u 3 w l
pause -1
set terminal png
set output 'pid_nnp_auf1000_rms_cerr_iderr.png'
replot
