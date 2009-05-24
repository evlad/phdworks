set title "NOC in not stationary plant cases: P(z)=Kz/(z-T)"
set grid
set xlabel "T"
set x2label "K"
set x2tics
set ylabel "MSE"
set label "Standard parameters" at graph 0.48,0.5 center rotate
set arrow from 0.5,0.35 to 0.5,0.8 heads
plot 'tau_vs_mse.dat' t "MSE(T)" w l, 'gain_vs_mse.dat' axes x2y1 t "MSE(K)" w l
#set terminal postscript landscape monochrome
#set output 'noc_tau_gain_vs_mse.ps'
#replot
#set terminal png
#set output 'noc_tau_gain_vs_mse.png'
#reset
