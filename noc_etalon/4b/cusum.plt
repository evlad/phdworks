set grid
set title "Imaging point of cummulative sum"
set output "cusum.png"
set terminal png
set xlabel "Time"
plot 'cusum.dat' w l, 4.94 w l
reset