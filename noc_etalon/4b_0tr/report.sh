gnuplot u_ny_d2d_eps_ru.plt
pstoimg -antialias -type png -density 300 u_ny_d2d_ru.eps
mv u_ny_d2d_ru.png /tmp/u_ny_d2d_ru.png
convert /tmp/u_ny_d2d_ru.png -crop 1340x880+110+80 u_ny_d2d_ru.png
