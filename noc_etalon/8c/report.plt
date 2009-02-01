# $Id: report.plt,v 1.1 2009-02-01 19:33:06 evlad Exp $
set grid
set title "Plant change: gain=1 to gain=1.1"
set output "noc_noadapt_gain_change1.png"
set terminal png
plot [450:550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=1.1 to gain=1.2"
set output "noc_noadapt_gain_change2.png"
set terminal png
plot [950:1050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=1.2 to gain=1.3"
set output "noc_noadapt_gain_change3.png"
set terminal png
plot [1450:1550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=1.3 to gain=1.4"
set output "noc_noadapt_gain_change4.png"
set terminal png
plot [1950:2050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: gain=1.4 to gain=1.5"
set output "noc_noadapt_gain_change5.png"
set terminal png
plot [2450:2550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
