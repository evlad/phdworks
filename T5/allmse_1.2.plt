reset
set grid
set logscale xy
#plot 'nno_trace_1.2_0.dat' u 7 w lines, \
#	'nno_trace_1.2_0.dat' u 8 w lines
plot 'nno_trace_1.2_0.dat' u 8 w lines, \
	'nno_trace_1.2_1.dat' u 8 not w lines, \
	'nno_trace_1.2_2.dat' u 8 not w lines

#	'nno_trace_0.2_3.dat' u 8 not w lines, \
#	'nno_trace_0.2_4.dat' u 8 not w lines, \
#	'nno_trace_0.2_5.dat' u 8 not w lines, \
#	'nno_trace_0.2_6.dat' u 8 not w lines, \
#	'nno_trace_0.2_7.dat' u 8 not w lines

#	'nno_trace_0.2_8.dat' u 8 not w lines, \
#	'nno_trace_0.2_9.dat' u 8 not w lines
