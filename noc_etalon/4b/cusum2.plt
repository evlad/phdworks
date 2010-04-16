set grid
set title "Imaging point of cummulative sum"
set output "cusum2.png"
set terminal png
set xlabel "Time"
plot [300:505] [0:3] 'cusum2.dat' t "Imaging point" w l, 2 t "Hnop=2" w l
reset
