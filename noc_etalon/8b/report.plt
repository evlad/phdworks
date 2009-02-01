# $Id: report.plt,v 1.1 2009-02-01 18:36:44 evlad Exp $
set grid
set title "Plant change: \\tau=-0.5 to \\tau=-0.4"
set output "noc_noadapt_tau_change1.png"
set terminal png
plot [450:550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.4 to \\tau=-0.3"
set output "noc_noadapt_tau_change2.png"
set terminal png
plot [950:1050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.3 to \\tau=-0.2"
set output "noc_noadapt_tau_change3.png"
set terminal png
plot [1450:1550] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
set title "Plant change: \\tau=-0.2 to \\tau=-0.1"
set output "noc_noadapt_tau_change4.png"
set terminal png
plot [1950:2050] [-4:4] "r.dat" w l, "ny.dat" w l, "e.dat" w l
