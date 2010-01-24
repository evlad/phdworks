gnuplot id_err_eps_ru.plt
pstoimg -antialias -type png -density 300 id_err_ru.eps
gnuplot cusum_eps_ru.plt
pstoimg -antialias -type png -density 300 cusum_ru.eps
gnuplot control_err_eps_ru.plt
pstoimg -antialias -type png -density 300 control_err_ru.eps
