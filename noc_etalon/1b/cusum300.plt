set grid
set title "Imaging point of cummulative sum"
set output "cusum300.png"
set terminal png
set xlabel "Time"
plot 'cusum300.dat' w l, 300 w l
reset