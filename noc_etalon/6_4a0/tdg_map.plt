#set view map
#splot 'tdg_map.dat' w pm3d
set contour
unset surface
set cntrparam bspline
set cntrparam levels discrete 1,2,4,6,8,10
splot 'tdg_map.dat' w l
