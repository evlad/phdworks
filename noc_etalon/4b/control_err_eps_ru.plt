set grid
set encoding koi8r
set title "������� �������� �� �������� ������������� ����������"
set output "control_err_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set xlabel "�����"
plot [450:550] 'r_out.dat' t '�������' w l, 'ny.dat' t '���������� ��' w l
