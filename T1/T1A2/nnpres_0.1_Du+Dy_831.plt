load "nnpres_setup.plt"
splot [x=1:4] [y=1:4] 'nnpres_0.1_Du+Dy_831.dat' not w lines
pause -1 "Press RETURN to make picture file"
set terminal postscript landscape enhanced "Helvetica-Oblique" 18
set output 'nnpres_0.1_Du+Dy_831.ps'
replot
set terminal x11
