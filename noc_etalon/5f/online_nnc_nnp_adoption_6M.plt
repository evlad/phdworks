set grid
set logscale
set terminal png
set title "plant_notst3.cof: online adoption both NNP and NNC L>6M\nnnc auf=5k eta=0.5;0.3, nnp auf=1k eta=0.03;0.01 (eta_scale_by_auf=1)"
set output 'online_nnc_nnp_adoption_6M.png'
plot 'iderr_trace.dat' u 3 t "identification error" w l, \
     'cerr_trace.dat' u 3 t "control error" w l
