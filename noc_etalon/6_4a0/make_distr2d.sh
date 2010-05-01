#!/bin/sh

Distr2D tdg_u.dat tdg_ny.dat tdg_map.txt tdg_map.dat <<EOF
-3
3
12
-4
4
16
EOF

tee tdg_map.plt >/dev/null <<EOF
#set view map
#splot 'tdg_map.dat' w pm3d
set contour
unset surface
set cntrparam bspline
set cntrparam levels discrete 1,2,4,6,8,10
splot 'tdg_map.dat' w l
EOF

# End of file
