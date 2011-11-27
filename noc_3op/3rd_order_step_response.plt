# -*-coding: koi8-r;-*-
set grid
set encoding koi8r
set output "3rd_order_step_response_ru.eps"
set terminal postscript eps enhanced monochrome
set xlabel "Время, отсчеты"
set ylabel "Наблюдаемая величина"
plot [0:40] [-0.1:1.3] '001/r.dat' t "Уставка" w l lw 2, \
     	    	       '001/ny.dat' t "Выход объекта" w l lw 2
