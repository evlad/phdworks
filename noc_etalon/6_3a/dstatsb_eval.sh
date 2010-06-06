#!/bin/sh

DSUB_DELAY=-1 dsub r.dat ny.dat >e.dat
dstatsb 10000 1 RMS,STDDEV,TINDEX e.dat e_10k.dat
