set view map
set terminal png
set output '0tr/u_ny.png'
splot '0tr/u_ny.dat' with pm3d
set output '0ev/u_ny.png'
splot '0ev/u_ny.dat' with pm3d
