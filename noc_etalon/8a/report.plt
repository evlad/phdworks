# $Id: report.plt,v 1.1 2009-02-01 16:26:00 evlad Exp $
set grid
set title "Plant change: \\tau=-0.5 to \\tau=-0.6"
set output "noc_noadapt_tau_change1.png"
set terminal png
plot [450:550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.6 to \\tau=-0.7"
set output "noc_noadapt_tau_change2.png"
set terminal png
plot [950:1050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.7 to \\tau=-0.8"
set output "noc_noadapt_tau_change3.png"
set terminal png
plot [1450:1550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.8 to \\tau=-0.9"
set output "noc_noadapt_tau_change4.png"
set terminal png
plot [1950:2050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
