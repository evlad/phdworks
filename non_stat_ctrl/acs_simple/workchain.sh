#!/bin/sh
ACS_EVENTS=5 ./acs_simple case1.cof 1 2 5 0 case1_acs.dat
drand 500 0 1 case1f1.tf >case1f1_probe.dat
drand 500 0 1 case1f2.tf >case1f2_probe.dat
StatAn case1f1_probe.dat
StatAn case1f2_probe.dat
Distr1D case1f1_probe.dat case1f1_graph.dat
Distr1D case1f2_probe.dat case1f2_graph.dat
ACS_EVENTS=5 ./acs_simple case2.cof 1 2 5 0 case2_acs.dat
drand 500 0 1 case2f2.tf >case2f2_probe.dat
StatAn case2f2_probe.dat
Distr1D case2f2_probe.dat case2f2_graph.dat
ACS_EVENTS=5 ./acs_simple case3.cof 1 2 5 0 case3_acs.dat
drand 500 0 1 case3f2.tf >case3f2_probe.dat
StatAn case3f2_probe.dat
Distr1D case3f2_probe.dat case3f2_graph.dat
gnuplot distr1d_cases123.plt
gnuplot case1_acs.plt
gnuplot case2_acs.plt
gnuplot case3_acs.plt
