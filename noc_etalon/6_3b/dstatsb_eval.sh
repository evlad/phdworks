#!/bin/sh

dsub ../6_3/r.dat ny.dat >e.dat
dstatsb 10000 1 RMS,STDDEV,TINDEX e.dat e_10k.dat

dsub ny.dat nn_y.dat >id_e.dat
dstatsb 10000 1 RMS,STDDEV,TINDEX id_e.dat id_e_10k.dat

