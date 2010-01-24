set grid
set encoding koi8r
set output "noc_after_eval_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
set title "������������ ����������� ���������� ����� ��������� � ��������"
set xlabel "�����"
set xtics ("10100" 100, "10120" 120, "10140" 140, "10160" 160, "10180" 180, \
    	   "10200" 200)
plot [100:200] \
     "r_out.dat" t "�������" w l, \
     "ny.dat" t "���������� ��" w l
