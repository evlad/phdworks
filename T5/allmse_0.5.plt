reset
set grid
set logscale xy
plot 'nno_trace_0.5_0.dat' u 8 w lines, \
	'nno_trace_0.5_1.dat' u 8 not w lines, \
	'nno_trace_0.5_2.dat' u 8 not w lines, \
	'nno_trace_0.5_3.dat' u 8 not w lines, \
	'nno_trace_0.5_4.dat' u 8 not w lines, \
	'nno_trace_0.5_5.dat' u 8 not w lines, \
	'nno_trace_0.5_6.dat' u 8 not w lines, \
	'nno_trace_0.5_7.dat' u 8 not w lines, \
	'nno_trace_0.5_8.dat' u 8 not w lines, \
	'nno_trace_0.5_9.dat' u 8 not w lines
