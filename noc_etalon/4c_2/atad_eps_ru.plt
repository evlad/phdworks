set grid
set encoding koi8r
set xlabel 'H���'
set ylabel '������� ����� ������������'
set output "atad_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
plot 'atad_10k.txt' w l not
