reset
set grid
set logscale xy
plot 'nno_trace_0.1_0.dat' u 8 w lines, \
	'nno_trace_0.1_1.dat' u 8 not w lines, \
	'nno_trace_0.1_2.dat' u 8 not w lines, \
	'nno_trace_0.1_3.dat' u 8 not w lines, \
	'nno_trace_0.1_4.dat' u 8 not w lines, \
	'nno_trace_0.1_5.dat' u 8 not w lines, \
	'nno_trace_0.1_6.dat' u 8 not w lines, \
	'nno_trace_0.1_7.dat' u 8 not w lines, \
	'nno_trace_0.1_8.dat' u 8 not w lines, \
	'nno_trace_0.1_9.dat' u 8 not w lines
