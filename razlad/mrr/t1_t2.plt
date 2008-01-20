# drawings on page 66 of Filatov's thesis
# $Id: t1_t2.plt,v 1.1 2008-01-20 19:40:35 evlad Exp $
set grid
set xlabel 'n'
plot [1:100] [-500:2000] \
     't1_Tlt.txt' u 1:2 w l t 'T  (m1=0.5 mx=0.0 h=7.44)', \
     't1_Tlt.txt' u 1:3 w l t 'T_a(m1=0.5 mx=0.0 h=7.44)', \
     't2_Tlt.txt' u 1:2 w l t 'T  (m1=1.0 mx=0.0 h=4.43)', \
     't2_Tlt.txt' u 1:3 w l t 'T_a(m1=1.0 mx=0.0 h=4.43)'
pause -1
plot [1:100] [-300:500] \
     't1_Tzp.txt' u 1:2 w l t 'tau   (m1=0.5 mx=0.5 h=7.44)', \
     't1_Tzp.txt' u 1:3 w l t 'tau_a (m1=0.5 mx=0.5 h=7.44)', \
     't2_Tzp.txt' u 1:2 w l t 'tau   (m1=1.0 mx=1.0 h=4.43)', \
     't2_Tzp.txt' u 1:3 w l t 'tau_a (m1=1.0 mx=1.0 h=4.43)'
