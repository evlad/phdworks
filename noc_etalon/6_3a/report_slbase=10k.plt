#!DSUB_DELAY=-1 dsub r.dat ny.dat >e-1.dat
#!sed 's/-//g' e-1.dat >cerr.dat
set grid
set title "Original plant conditions: control MSE (sliding base=10k)"
set xlabel "Time, samples"
set ylabel "MSE"
set logscale y
set terminal png
set output 'cmp_cerr_3a_3b_2M_slb10k.png'
plot [0:2000000] [0.01:40] \
     'e_10k.dat' u 3:1 t "NN-C without adoption" w l, \
     '../6_3b/e_10k.dat' u 3:1 t "NN-C and NN-P adoption" w l, \
     '../6_3b/id_e_10k.dat' u 3:1 t "Identification while adoption" w l
reset
