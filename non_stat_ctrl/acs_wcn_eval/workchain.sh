#!/bin/sh
# Data preparation:
#head -500 ../../noc_etalon/4b/nn_e.dat >n1.dat
#tail -500 ../../noc_etalon/4b/nn_e.dat >n2.dat
#cat n1.dat n2.dat >n.dat
#drand 500 0.0008 0.148 >w1.dat
#drand 500 -0.0133 0.798 >w2.dat
#cat w1.dat w2.dat >w.dat
#drand 500 0 1 c1.tf >c1.dat
#drand 500 0 1 c2.tf >c2.dat
#cat c1.dat c2.dat >c.dat
../acs_simple/acs_simple w.dat 0.148 0.798 20 0 w_ip.dat
../acs_simple/acs_simple c.dat 0.148 0.798 20 0 c_ip.dat
../acs_simple/acs_simple n.dat 0.148 0.798 20 0 n_ip.dat
gnuplot imgpnt.plt
