##
## for eta in 0.05 0.1 0.2 0.5
## do
##   dcontrf dcontrf.par \
##           eta_output=$eta \
##           cerr_trace_file=cerr_trace_nnc_auf=5k_eta=$eta.dat \
##           iderr_trace_file=iderr_trace_nnc_auf=5k_eta=$eta.dat
##   echo eta=$eta done
## done
##

set grid
set logscale
set terminal png
set output 'iderr_trace_eta_nnc_auf=5k.png'
set title "plant3_notst.cof: identification error depending eta_output"
plot [1000:1000000] \
     'iderr_trace_nnc_auf=5k_eta=0.05.dat' u 3 t 'eta=0.05'   w l, \
     'iderr_trace_nnc_auf=5k_eta=0.1.dat'  u 3 t 'eta=0.1'    w l, \
     'iderr_trace_nnc_auf=5k_eta=0.2.dat'  u 3 t 'eta=0.2'    w l, \
     'iderr_trace_nnc_auf=5k_eta=0.5.dat'  u 3 t 'eta=0.5'    w l

#     'cerr_trace_nnc_auf=0.dat'           u 3 t 'NN-C=const' w l, \
