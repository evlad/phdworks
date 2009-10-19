set grid
set xlabel 'Hnop'
set ylabel 'T'
plot 'atad_10k.txt' w l not
pause -1
set terminal png
set output 'atad.png'
replot
