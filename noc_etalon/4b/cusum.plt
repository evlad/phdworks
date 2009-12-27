set grid
set title "Imaging point of cummulative sum"
set output "cusum.png"
set terminal png
set xlabel "Time"
set logscale y
plot [0:600] 'cusum.dat' t "Imaging point" w l, 4 t "Hnop=4" w l
reset
