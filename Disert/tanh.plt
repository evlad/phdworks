set nokey
set grid
set ytics border -1,1,1
plot [t=-10:10] [-1.2:1.2] 2*(1/(1+exp(-t))-0.5) with lines linewidth 4.0
pause -1 "Press RETURN to make an output file"
set terminal postscript landscape enhanced "Helvetica-Oblique" 18
set output 'tanh.ps'
replot
set terminal x11
#set terminal windows
