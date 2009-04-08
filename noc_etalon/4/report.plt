set grid
set output "noc_eval.png"
set terminal png
plot [100:200] "r.dat" w l, "ny.dat" w l
set output "noc_vs_woc_eval.png"
set terminal png
set title "NOC vs. WOC: standard conditions"
plot [100:200] \
     "r.dat" t "Reference" w l, \
     "ny.dat" t "NOC track" w l, \
     "ny_woc.dat" t "WOC track" w l
