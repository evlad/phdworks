reset
set grid
set logscale xy
plot 'nno_trace_0.3_0.dat' u 8 w lines, \
	'nno_trace_0.3_1.dat' u 8 not w lines, \
	'nno_trace_0.3_2.dat' u 8 not w lines, \
	'nno_trace_0.3_3.dat' u 8 not w lines, \
	'nno_trace_0.3_4.dat' u 8 not w lines, \
	'nno_trace_0.3_5.dat' u 8 not w lines, \
	'nno_trace_0.3_6.dat' u 8 not w lines, \
	'nno_trace_0.3_7.dat' u 8 not w lines, \
	'nno_trace_0.3_8.dat' u 8 not w lines, \
	'nno_trace_0.3_9.dat' u 8 not w lines
