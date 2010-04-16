set grid
set encoding koi8r
set title "Изображающая точка АКС при обнаружении разладки"
set output "cusum2_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "Время"
plot [300:505] [0:3] 'cusum2.dat' t "Изображающая точка" w l, 2 t "Hпор=2" w l
