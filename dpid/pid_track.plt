reset
set grid
set title "PID control with noise"
# "Helvetica, 10"
plot [t=0:100] 'r.dat' t "Reference" w lines, 'y.dat' t "Plant output" w lines
pause -1
set terminal postscript landscape "Helvetica" 8
set output "pid_track.ps"
replot
set terminal x11
