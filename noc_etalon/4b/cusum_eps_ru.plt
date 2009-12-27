set grid
set encoding koi8r
set title "Изображающая точка АКС при обнаружении разладки"
set output "cusum_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "Время"
set logscale y
plot [0:600] 'cusum.dat' t "Изображающая точка" w l, 4 t "Hпор=4" w l
