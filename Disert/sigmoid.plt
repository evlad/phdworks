set nokey
set grid
set ytics border 0,0.5,1
plot [t=-10:10] 1/(1+exp(-t)) with lines linewidth 2.0
pause -1 "Press RETURN to make an output file"
set terminal eepic
#set terminal postscript
set output 'sigmoid.pic'
replot
set terminal windows
