reset
set xlabel 'Time, s'
set grid
set grid mxtics
set grid mytics
plot [294:236] [-0.6:0.8] \
     'meand_cmp.dat' u 1:2 t "Set point" w l lw 2, \
     'meand_cmp.dat' u 1:3 t "Wiener controller" w l lw 2, \
     'meand_cmp.dat' u 1:4 t "Neural controller" w l lw 2
pause -1
set terminal postscript landscape enhanced "Helvetica-Oblique" 18
set output 'meand_cmp.ps'
replot
set terminal x11
