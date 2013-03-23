#!/bin/sh

# Build all NeuroArchitector parts
# $Id: build_na.sh,v 1.2 2006-03-25 15:23:09 evlad Exp $

# Set appropriate path
targetdir=$HOME/nnacs
mkdir -p $targetdir

libdirs='Matrix.041 NeuArch'
progdirs='NaTools dtools dcsloop dplantid dcontrp dcontrf noc_labs'

echo "#######################"
echo "### Build libraries ###"
echo "#######################"
for dir in $libdirs
do
  cd $dir && {
      echo "### $dir ###"
      make PREFIX=$targetdir FLAGS="$FLAGS" $* all
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
      make PREFIX=$targetdir FLAGS="$FLAGS" $* install
      cd ..
  }
done

# End of file
