# -*-coding: koi8-r;-*-
set grid
set encoding koi8r
set output "woc_stoch_diff_plant_rus.eps"
set terminal postscript eps enhanced monochrome "Arial" 16
# "Arial" 24
set xlabel "�����"
plot [300:400] \
     '../4/r.dat' w l lw 2 t "�������", \
     'ny_woc.dat' w l lw 2 t "���������� ��"
#pause -1
set output "noc_stoch_diff_plant_rus.eps"
set terminal postscript eps enhanced monochrome "Arial" 16
set xlabel "�����"
plot [300:400] \
     '../4/r.dat' w l lw 2 t "�������", \
     'ny_noc.dat' w l lw 2 t "���������� ��"
