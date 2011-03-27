# -*-coding: koi8-r;-*-
# Good import of EPS into pdfLaTeX with cyrillic labels
set grid
set encoding koi8r
#set title "�������� �������� ��� ��� ����������"
set xlabel "�����, ���."
set ylabel "����������� ��������� �������, K"
set y2label "����� ����������, �^3/���"
set y2tics
set terminal postscript eps enhanced nofontfiles monochrome
#set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set output "cstr_pid_ru.eps"
plot [0:500] [352:366] [0:500] [0:0.14] 'steps.dat' t "�������" w l, \
     'pid_ny.dat' t "���������" w l, \
     'pid_u.dat' axes x1y2 t "����������" w l
