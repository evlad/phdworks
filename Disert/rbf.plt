set nokey
set grid
#set ytics border -1,1,0.2
plot [t=-3:3] [-0.2:1.2] exp(-t*t) with lines linewidth 4.0
pause -1 "Press RETURN to make an output file"
set terminal postscript landscape enhanced "Helvetica-Oblique" 18
set output 'rbf.ps'
replot
set terminal x11
#set terminal windows
