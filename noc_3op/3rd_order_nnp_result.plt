# -*-coding: koi8-r;-*-
set grid
set encoding koi8r
set output "3rd_order_nnp_result_ru.eps"
set terminal postscript eps enhanced monochrome
set xlabel "Время, отсчеты"
set ylabel "Наблюдаемая величина"
plot [0:150] [-15:15] '005/tr_y_learn.dat' t "Выход объекта" w l lw 2, \
     	     	      '005/nn_y_learn.dat' t "Предсказание модели" w l lw 2
