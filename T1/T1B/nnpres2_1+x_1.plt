reset
set hidden3d
set contour both
set xtics 0.1
set ytics 1
set ylabel 'm' 5,-1
set xlabel 'd' 0,-1
set view 75,350
splot [x=0.1:0.9] [y=1:4] 'nnpres2_1+x_1.dat' not w lines
pause -1 "Press RETURN to make picture file"
set terminal postscript landscape enhanced
set output 'nnpres2_1+x_1.ps'
replot
set terminal x11
