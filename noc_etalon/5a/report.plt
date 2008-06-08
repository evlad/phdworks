set grid
set output "noc_notst_eval.png"
set terminal png
plot [450:550] "r.dat" w l, "ny.dat" w l, "e.dat" w l
