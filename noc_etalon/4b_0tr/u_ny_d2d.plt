set xlabel 'u'
set ylabel 'y'
set view map
set contour
unset surface
set cntrparam bspline
set cntrparam levels discrete 1,5,10,15,20,25,30
splot 'u_ny_d2d.dat' w l
pause -1
#set terminal postscript landscape
#set output 'u_ny_d2d.ps'
set terminal png large size 1024,768 crop
set output 'u_ny_d2d.png'
replot
