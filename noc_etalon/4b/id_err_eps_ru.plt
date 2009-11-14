reset
set grid
set encoding koi8r
set title "Обнаружение разладки по ошибке идентификации"
set output "id_err_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "Время"
plot [450:550] 'ny.dat' t 'Выход объекта' w l, 'nn_y.dat' t 'Выход НС-О' w l, 'nn_e.dat' t 'Ошибка идентификации' w l
