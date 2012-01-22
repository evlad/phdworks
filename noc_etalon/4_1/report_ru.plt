# -*-coding: koi8-r;-*-
set grid
set logscale x
set encoding koi8r
set output "woc_noc_freq_emax_ru.eps"
set terminal postscript eps enhanced monochrome
set xlabel "Частота, 1/отсчеты"
set ylabel "Ошибка управления"
plot [0.01:0.3] [0.4:3.0] \
     'result.dat' u (1/$1):2 w l lw 2 t "Винеровский", \
     'result.dat' u (1/$1):4 w l lw 2 t "Нейросетевой"
#pause -1
set output "woc_noc_freq_mse_ru.eps"
set terminal postscript eps enhanced monochrome
set xlabel "Частота, 1/отсчеты"
set ylabel "СКО управления"
plot [0.01:0.3] [0:2.5] \
     'result.dat' u (1/$1):3 w l lw 2 t "Винеровский", \
     'result.dat' u (1/$1):5 w l lw 2 t "Нейросетевой"
