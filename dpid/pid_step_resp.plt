reset
set grid
set title "Step response in PID controlled closed loop system" "Helvetica, 10"
plot [t=0:15] 'step.dat' t "Step" w lines, 'resp.dat' t "Response" w lines
pause -1
set terminal postscript landscape "Helvetica" 8
set output "pid_step_resp.ps"
replot
set terminal x11
