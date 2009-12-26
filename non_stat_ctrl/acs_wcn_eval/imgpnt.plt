set grid
set terminal png
set title "White noise"
set output "w_ip.png"
plot [0:1000] [0:50] 'w_ip.dat' w l, 20
set title "Colored noise"
set output "c_ip.png"
plot [0:1000] [0:50] 'n_ip.dat' w l, 20
set title "NN-P error"
set output "n_ip.png"
plot [0:1000] [0:50] 'n_ip.dat' w l, 20
