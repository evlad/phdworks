reset
set grid
set logscale xy
plot 'nno_trace_0.05_0.dat' u 8 w lines, \
	'nno_trace_0.05_1.dat' u 8 not w lines, \
	'nno_trace_0.05_2.dat' u 8 not w lines, \
	'nno_trace_0.05_3.dat' u 8 not w lines, \
	'nno_trace_0.05_4.dat' u 8 not w lines, \
	'nno_trace_0.05_5.dat' u 8 not w lines, \
	'nno_trace_0.05_6.dat' u 8 not w lines, \
	'nno_trace_0.05_7.dat' u 8 not w lines, \
	'nno_trace_0.05_8.dat' u 8 not w lines, \
	'nno_trace_0.05_9.dat' u 8 not w lines
