set xlabel 'r'
set ylabel 'e'
set view map
set contour
unset surface
set cntrparam bspline
set cntrparam levels discrete 1,20,40,60
splot 'FILENAME.dat' w l
#pause -1
set terminal postscript landscape
set output 'FILENAME.ps'
#set terminal png large size 1024,768 crop
#set output 'FILENAME.png'
replot
reset
