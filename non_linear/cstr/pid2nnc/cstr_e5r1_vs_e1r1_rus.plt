# -*-coding: koi8-r;-*-
# To produce data:
# $ ./teach_nnc.sh e1r1_74
# $ ./teach_nnc.sh e5r1_95
# $ ./test_nnc_origsys.sh e1r1_74 test
# $ ./test_nnc_origsys.sh e5r1_95 test
# Good import of EPS into pdfLaTeX with cyrillic labels
set encoding koi8r
set grid
set logscale
set xlabel "�����, �����"
set ylabel "������"
#set title "��������� �������� ���������� ��-� (��������� �������)"
set terminal postscript eps enhanced nofontfiles monochrome
set output "cstr_e5r1_vs_e1r1_training_learn_rus.eps"
plot [1:2000] [1e-7:1e-4] \
     'nnc_e5r1_95_trace.dat' u 3 t "��-� � d=5" w l, \
     'nnc_e1r1_74_trace.dat' u 3 t "��-� � d=1" w l
#pause -1
#set title "��������� �������� ���������� ��-� (�������� �������)"
set terminal postscript eps enhanced nofontfiles monochrome
set output "cstr_e5r1_vs_e1r1_training_test_rus.eps"
plot [1:2000] [1e-7:1e-4] \
     'nnc_e5r1_95_trace.dat' u 6 t "��-� � d=5" w l, \
     'nnc_e1r1_74_trace.dat' u 6 t "��-� � d=1" w l
#pause -1
unset logscale
set xlabel "�����, ���"
set ylabel "����� ����������, �^3/���"
#set title "��������� ��������� ��-� (��� �������)"
set terminal postscript eps enhanced nofontfiles monochrome
set output "cstr_e5r1_vs_e1r1_outloop_rus.eps"
plot [400:1000] [0:0.02] 'u_test.dat' t "���" w l, \
     'nn_u_test_e5r1_95.dat' t "��-� � d=5" w l, \
     'nn_u_test_e1r1_74.dat' t "��-� � d=1" w l
#pause -1
set xlabel "�����, ���"
set ylabel "����� ����������, �^3/���"
#set title "��������� ��������� ��-� (� �������)"
set terminal postscript eps enhanced nofontfiles monochrome
set output "cstr_e5r1_vs_e1r1_inloop_rus.eps"
plot [400:1000] [0:0.02] 'u_test.dat' t "���" w l, \
     'nnc_u_test_e5r1_95.dat' t "��-� � d=5" w l, \
     'nnc_u_test_e1r1_74.dat' t "��-� � d=1" w l
#pause -1
