set grid
set encoding koi8r
set title "������������ ����� ��� ��� ����������� ��������"
set output "cusum5k_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "�����"
plot [0:600] 'cusum5k.dat' t "������������ �����" w l, 5000 t "H���=5000" w l
