set grid
set encoding koi8r
set output "noc_after_eval_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "������������ ����������� ���������� ����� ��������� � ��������"
set xlabel "�����"
plot [100:200] \
     "r_out.dat" t "�������" w l, \
     "ny.dat" t "���������� ��" w l
