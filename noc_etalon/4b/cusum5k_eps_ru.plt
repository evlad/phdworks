set grid
set encoding koi8r
set title "Изображающая точка АКС при обнаружении разладки"
set output "cusum5k_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "Время"
plot [0:600] 'cusum5k.dat' t "Изображающая точка" w l, 5000 t "Hпор=5000" w l
