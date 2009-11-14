set grid
set encoding koi8r
set title "Влияние разладки на качество нейросетевого управления"
set output "control_err_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "Время"
plot [450:550] 'r_out.dat' t 'Уставка' w l, 'ny.dat' t 'Наблюдение ОУ' w l
