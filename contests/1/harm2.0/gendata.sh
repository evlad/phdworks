#!/bin/bash

nperiods=100

for period in 3 4 5 6 7 8 9 \
    10 11 12 13 14 15 16 17 18 19 \
    20 21 22 23 24 25 26 27 28 29 30
do
    mkdir -p $period && cd $period
    len=`expr $period \* $nperiods`
    echo "*** Period $period, length $len ***"

    # Make harmonic reference signal
    if [ ! -f refer.dat ]; then
	dsin $len $period >tmp.dat
	dmult 2.0 tmp.dat >refer.dat
	rm -f tmp.dat
	echo "    ... reference signal is made"
    fi
    # Make noise signal
    if [ ! -f noise.dat ]; then
	drand $len 0 1 ../../noise.tf >noise.dat
	echo "    ... noise signal is made"
    fi
    cd ..
done

# End of file
