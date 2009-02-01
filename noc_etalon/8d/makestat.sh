#!/bin/sh
# $Id: makestat.sh,v 1.1 2009-02-01 19:41:35 evlad Exp $

dcsloop dcsloop.par

head -500 e.dat >e1.dat
head -1000 e.dat | tail -500 >e2.dat
head -1500 e.dat | tail -500 >e3.dat
head -2000 e.dat | tail -500 >e4.dat
head -2500 e.dat | tail -500 >e5.dat
tail -500 e.dat >e6.dat
( echo "Original gain=1.0, MSE=`dmse e1.dat`"
  echo " Changed gain=0.9, MSE=`dmse e2.dat`"
  echo " Changed gain=0.8, MSE=`dmse e3.dat`"
  echo " Changed gain=0.7, MSE=`dmse e4.dat`"
  echo " Changed gain=0.6, MSE=`dmse e5.dat`"
  echo " Changed gain=0.5, MSE=`dmse e6.dat`" ) | tee statistics.txt
