set grid

set output "nncf_notst.png"
set terminal png
set logscale
plot "cerr_trace.dat" u 3 w l, "iderr_trace.dat" u 3 w l

set output "nncf_on_change.png"
set terminal png
unset logscale
set title "NOC at the plant change"
plot [450:550] "r_out.dat" w l, "ny.dat" w l

set output "nncf_adopted.png"
set terminal png
unset logscale
set title "NOC adopted the plant change"
plot [9850:9950] "r_out.dat" w l, "ny.dat" w l

plot "iderr_trace_nnpauf=500.dat" u 3 w l, "iderr_trace_nnpauf=1k.dat" u 3 w l, "iderr_trace_nnpauf=5k.dat" u 3 w l
