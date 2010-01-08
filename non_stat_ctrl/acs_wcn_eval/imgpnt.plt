set grid
set terminal png
set title "Disorder on white noise signal"
set output "w_ip.png"
plot [0:1000] [0:50] 'w_ip.dat' w l, 20
set title "Disorder on correlated random signal"
set output "c_ip.png"
plot [0:1000] [0:50] 'c_ip.dat' w l, 20
set title "Disorder on NN-P identification error signal"
set output "n_ip.png"
plot [0:1000] [0:50] 'n_ip.dat' w l, 20
