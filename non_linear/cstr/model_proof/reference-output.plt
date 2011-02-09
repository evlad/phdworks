set grid
set title "CSTR under original PID control"
set xlabel "Time, min"
set ylabel "Outflow temperature, K"
set terminal png
set output "reference-output.png"
plot [0:500] [352:366] 'refer_t.dat' u 1:2 t "Reference" w l, \
     'cstr_out.dat' u 1:5 t "Plant result" w l
