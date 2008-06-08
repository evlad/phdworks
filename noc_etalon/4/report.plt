set grid
set output "noc_eval.png"
set terminal png
plot [100:200] "r.dat" w l, "ny.dat" w l, "e.dat" w l
