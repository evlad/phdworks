set grid
set encoding koi8r
set xlabel 'Hпор'
set ylabel 'Среднее время запаздывания'
set output "atad_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
plot [0:11] [0:1.5] 'atad_10k.txt' u 1:2 w l t 's1/s0=2', \
     'atad_10k.txt' u 1:3 w l t 's1/s0=3', \
     'atad_10k.txt' u 1:4 w l t 's1/s0=4', \
     'atad_10k.txt' u 1:5 w l t 's1/s0=5'
