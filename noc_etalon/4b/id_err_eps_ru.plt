reset
set grid
set encoding koi8r
set title "����������� �������� �� ������ �������������"
set output "id_err_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "�����"
plot [450:550] 'ny.dat' t '����� �������' w l, 'nn_y.dat' t '����� ��-�' w l, 'nn_e.dat' t '������ �������������' w l
