#!/bin/sh

# Build all NeuroArchitector parts
# $Id: build_na.sh,v 1.2 2006-03-25 15:23:09 evlad Exp $

libdirs='Matrix.041 NeuArch'
progdirs='NaTools dtools dcsloop dplantid dcontrp dcontrf'

echo "#######################"
echo "### Build libraries ###"
echo "#######################"
for dir in $libdirs
do
  cd $dir && {
      echo "### $dir ###"
      make FLAGS="$FLAGS" $* all
      cd ..
  }
done

echo "######################"
echo "### Build programs ###"
echo "######################"
for dir in $progdirs
do
  cd $dir && {
      echo "### $dir ###"
      make FLAGS="$FLAGS" $* install
      cd ..
  }
done

# End of file
