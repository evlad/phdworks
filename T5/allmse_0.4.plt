reset
set grid
set logscale xy
plot 'nno_trace_0.4_0.dat' u 8 w lines, \
	'nno_trace_0.4_1.dat' u 8 not w lines, \
	'nno_trace_0.4_2.dat' u 8 not w lines, \
	'nno_trace_0.4_3.dat' u 8 not w lines, \
	'nno_trace_0.4_4.dat' u 8 not w lines, \
	'nno_trace_0.4_5.dat' u 8 not w lines, \
	'nno_trace_0.4_6.dat' u 8 not w lines, \
	'nno_trace_0.4_7.dat' u 8 not w lines, \
	'nno_trace_0.4_8.dat' u 8 not w lines, \
	'nno_trace_0.4_9.dat' u 8 not w lines
