set grid
set encoding koi8r
set title "������������ ����� ��� ��� ����������� ��������"
set output "cusum2_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "�����"
plot [300:505] [0:3] 'cusum2.dat' t "������������ �����" w l, 2 t "H���=2" w l
