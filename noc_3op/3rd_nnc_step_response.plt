# -*-coding: koi8-r;-*-
set grid
set encoding koi8r
set output "3rd_nnc_step_response_ru.eps"
set terminal postscript eps enhanced monochrome
set xlabel "Время, отсчеты"
set ylabel "Наблюдаемая величина"
plot [0:40] [-0.1:1.3] '014/r.dat' t "Уставка" w l lw 2, \
     	    	       '014/ny.dat' t "Выход объекта" w l lw 2
