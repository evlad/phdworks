set grid
set encoding koi8r
set title "������������ ����� ��� ��� ����������� ��������"
set output "cusum_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "�����"
set logscale y
plot [0:600] 'cusum.dat' t "������������ �����" w l, 4 t "H���=4" w l
