set nokey
set grid
set ytics border -1,1,1
plot [t=-10:10] 2*(1/(1+exp(-t))-0.5) with lines linewidth 4.0
pause -1 "Press RETURN to make an output file"
set terminal eepic
set output 'tanh.pic'
replot
set terminal windows
