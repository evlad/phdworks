#!/bin/sh
Distr2D 0tr/u.dat 0tr/ny.dat 0tr/u_ny.map 0tr/u_ny.dat <<EOF
-4
4
16
-4
4
16
EOF
Distr2D 0ev/u.dat 0ev/ny.dat 0ev/u_ny.map 0ev/u_ny.dat <<EOF
-4
4
16
-4
4
16
EOF
Distr2D 0me/u.dat 0me/ny.dat 0me/u_ny.map 0me/u_ny.dat <<EOF
-4
4
16
-4
4
16
EOF
Distr2D 3/u.dat 3/ny.dat 3/u_ny.map 3/u_ny.dat <<EOF
-4
4
16
-4
4
16
EOF
Distr2D 3me/u.dat 3me/ny.dat 3me/u_ny.map 3me/u_ny.dat <<EOF
-4
4
16
-4
4
16
EOF
gnuplot distrib_u_ny.plt
