reset
set grid
set logscale xy
plot 'nno_trace_0.dat' u 8 not w lines, \
	'nno_trace_1.dat' u 8 not w lines, \
	'nno_trace_2.dat' u 8 not w lines, \
	'nno_trace_3.dat' u 8 not w lines, \
	'nno_trace_4.dat' u 8 not w lines, \
	'nno_trace_5.dat' u 8 not w lines, \
	'nno_trace_6.dat' u 8 not w lines, \
	'nno_trace_7.dat' u 8 not w lines, \
	'nno_trace_8.dat' u 8 not w lines, \
	'nno_trace_9.dat' u 8 not w lines
pause -1
set terminal eepic
set output "mse_1+3_731_n500.pic"
replot
set terminal x11
