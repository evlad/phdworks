reset
set grid
set output "noc_after_eval.png"
set terminal png
set title "NOC evaluation after disorder adoption"
set xlabel "Time"
plot [100:200] \
     "r_out.dat" t "Reference" w l, \
     "ny.dat" t "Plant output" w l
#, \
#     "e.dat" t "Control error" w l
