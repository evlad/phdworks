reset
set logscale
set xlabel '{/Bookman-LightItalic=20 f}'
set grid
set grid mxtics
set grid mytics
plot [0.02:0.4] [0.001:0.4] \
     'nnp_mse_freq.dat' u 1:2 t "Step trained NN" w l lw 2, \
     'nnp_mse_freq.dat' u 1:3 t "Sine trained NN" w l lw 2, \
     'nnp_mse_freq.dat' u 1:4 t "Stoch. trained NN" w l lw 2
set terminal postscript landscape enhanced "Helvetica-Oblique" 18
set output 'nnp_mse_freq.ps'
replot
set terminal x11
