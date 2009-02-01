#!/bin/sh
# $Id: makestat.sh,v 1.1 2009-02-01 18:36:44 evlad Exp $

dcsloop dcsloop.par

head -500 e.dat >e1.dat
head -1000 e.dat | tail -500 >e2.dat
head -1500 e.dat | tail -500 >e3.dat
head -2000 e.dat | tail -500 >e4.dat
tail -500 e.dat >e5.dat
( echo "Original tau=-0.5, MSE=`dmse e1.dat`"
  echo " Changed tau=-0.4, MSE=`dmse e2.dat`"
  echo " Changed tau=-0.3, MSE=`dmse e3.dat`"
  echo " Changed tau=-0.2, MSE=`dmse e4.dat`"
  echo " Changed tau=-0.1, MSE=`dmse e5.dat`" ) | tee statistics.txt
