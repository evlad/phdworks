set grid
set encoding koi8r
set xlabel 'H���'
set ylabel '������� ����� ������ �������'
set output "atfa_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
plot 'atfa_50k.txt' w l not
