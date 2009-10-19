set grid
set xlabel 'Hnop'
set ylabel 'T'
plot 'atfa_50k.txt' w l not
pause -1
set terminal png
set output 'atfa.png'
replot
