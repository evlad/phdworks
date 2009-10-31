set grid
set title "Imaging point of cummulative sum"
set output "cusum5k.png"
set terminal png
set xlabel "Time"
plot [0:600] 'cusum5k.dat' t "Imaging point" w l, 5000 t "Hnop=5000" w l
reset
