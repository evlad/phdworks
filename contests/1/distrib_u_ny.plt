set view map
set terminal png
set xlabel "u"
set ylabel "n+y"
set output '0tr/u_ny.png'
splot '0tr/u_ny.dat' with pm3d
set output '0ev/u_ny.png'
splot '0ev/u_ny.dat' with pm3d
set output '0me/u_ny.png'
splot '0me/u_ny.dat' with pm3d
set output '3/u_ny.png'
splot '3/u_ny.dat' with pm3d
set output '3me/u_ny.png'
splot '3me/u_ny.dat' with pm3d
