reset
set grid
set output "noc_noc_eval.png"
set terminal png
set title "NOC vs. NOC: not stationary conditions"
plot [100:200] \
     "r_out.dat" t "Reference" w l, \
     "../4b_4old/ny.dat" t "NOC before adoption" w l, \
     "ny.dat" t "NOC after NNP and NNC adoption" w l
