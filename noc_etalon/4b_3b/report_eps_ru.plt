set grid
set encoding koi8r
set logscale
set output "nncf_training_eta_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "����������� �������� ��-� � ������� ���������� �� ������������ �������� ��������"
set xlabel "�����"
set ylabel "������ ����������"
plot [1:500000] \
     'cerr_traces_eta.tsv' u 1 t "0.5" w l, \
     'cerr_traces_eta.tsv' u 3 t "0.3" w l, \
     'cerr_traces_eta.tsv' u 4 t "0.2" w l, \
     'cerr_traces_eta.tsv' u 6 t "0.05" w l, \
     0.019 t "�� ��������" w l
