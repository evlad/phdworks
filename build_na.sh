#!/bin/sh

# Build all NeuroArchitector parts
# $Id: build_na.sh,v 1.1 2004-04-05 00:28:29 vlad Exp $

libdirs='Matrix.041 NeuArch'
progdirs='NaTools dtf dcsloop dplantid dcontrp dcontrf'

for dir in $libdirs
do
  cd $dir && {
      echo "*** $dir ***"
      make FLAGS="$FLAGS" $* all
      cd ..
  }
done

for dir in $progdirs
do
  cd $dir && {
      echo "*** $dir ***"
      make FLAGS="$FLAGS" $* install
      cd ..
  }
done

# End of file
