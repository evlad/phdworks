set logscale x
set grid
plot 'result.dat' u (1/$1):2 w l t "woc |e|max", \
     'result.dat' u (1/$1):4 w l t "noc |e|max", \
     'result.dat' u (1/$1):3 w l t "woc mse", \
     'result.dat' u (1/$1):5 w l t "noc mse"
