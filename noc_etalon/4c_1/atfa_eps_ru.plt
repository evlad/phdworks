set grid
set encoding koi8r
set xlabel 'Hпор'
set ylabel 'Среднее время ложной тревоги'
set output "atfa_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
plot 'atfa_100k.txt' u 1:2 w l t 's1/s0=2', \
     'atfa_100k.txt' u 1:3 w l t 's1/s0=3', \
     'atfa_100k.txt' u 1:4 w l t 's1/s0=4', \
     'atfa_100k.txt' u 1:5 w l t 's1/s0=5'
