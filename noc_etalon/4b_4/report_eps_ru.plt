set grid
set encoding koi8r
set output "noc_after_eval_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "Нейросетевое оптимальное управление после адаптации к разладке"
set xlabel "Время"
plot [100:200] \
     "r_out.dat" t "Уставка" w l, \
     "ny.dat" t "Наблюдение ОУ" w l
