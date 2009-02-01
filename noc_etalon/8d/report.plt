# $Id: report.plt,v 1.1 2009-02-01 19:41:35 evlad Exp $
set grid
set title "Plant change: gain=1 to gain=0.9"
set output "noc_noadapt_gain_change1.png"
set terminal png
plot [450:550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=0.9 to gain=0.8"
set output "noc_noadapt_gain_change2.png"
set terminal png
plot [950:1050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=0.8 to gain=0.7"
set output "noc_noadapt_gain_change3.png"
set terminal png
plot [1450:1550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=0.7 to gain=0.6"
set output "noc_noadapt_gain_change4.png"
set terminal png
plot [1950:2050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=0.6 to gain=0.5"
set output "noc_noadapt_gain_change5.png"
set terminal png
plot [2450:2550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
