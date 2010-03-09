set grid
set title 'Delta impulse response to WMR (dt=0.1s)'
plot 'u.dat' u 1 t 'L,R Volts' w l, 'y.dat' u 2 t 'Coord' w l, 'y.dat' u 6 t 'Velocity' w l
