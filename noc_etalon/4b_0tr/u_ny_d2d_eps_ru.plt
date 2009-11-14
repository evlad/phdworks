set encoding koi8r
set xlabel 'u'
set ylabel 'y'
set view map
set contour
unset surface
set cntrparam bspline
set cntrparam levels discrete 1,5,10,15,20,25,30
set output "u_ny_d2d_ru.eps"
set terminal postscript 'NimbusSanL-Regu' eps enhanced monochrome
splot 'u_ny_d2d.dat' w l
