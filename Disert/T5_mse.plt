set xtics (0.05, 0.1, 0.2, 0.3, 0.4, 0.5)
set terminal postscript landscape enhanced "Helvetica" 20
set output 'T5_mse_mean_t0.ps'
plot 'T5_mse_mean_t0.dat' u 1:2 t "{/Times-Italic N@^o}_{1+3,1}" w l, \
	'T5_mse_mean_t0.dat' u 1:3 t "{/Times-Italic N@^o}_{1+3,4,1}" w l, \
	'T5_mse_mean_t0.dat' u 1:4 t "{/Times-Italic N@^o}_{1+3,7,4,1}" w l
set output 'T5_mse_mean_t400.ps'
plot 'T5_mse_mean_t400.dat' u 1:2 t "{/Times-Italic N@^o}_{1+3,1}" w l, \
	'T5_mse_mean_t400.dat' u 1:3 t "{/Times-Italic N@^o}_{1+3,4,1}" w l, \
	'T5_mse_mean_t400.dat' u 1:4 t "{/Times-Italic N@^o}_{1+3,7,4,1}" w l
set output 'T5_mse_stddev_t0.ps'
plot 'T5_mse_stddev_t0.dat' u 1:2 t "{/Times-Italic N@^o}_{1+3,1}" w l, \
	'T5_mse_stddev_t0.dat' u 1:3 t "{/Times-Italic N@^o}_{1+3,4,1}" w l, \
	'T5_mse_stddev_t0.dat' u 1:4 t "{/Times-Italic N@^o}_{1+3,7,4,1}" w l
set output 'T5_mse_stddev_t400.ps'
plot 'T5_mse_stddev_t400.dat' u 1:2 t "{/Times-Italic N@^o}_{1+3,1}" w l, \
	'T5_mse_stddev_t400.dat' u 1:3 t "{/Times-Italic N@^o}_{1+3,4,1}" w l, \
	'T5_mse_stddev_t400.dat' u 1:4 t "{/Times-Italic N@^o}_{1+3,7,4,1}" w l
set terminal x11
