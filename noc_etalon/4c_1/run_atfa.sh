#!/bin/sh

# Run experiment for average time of false alarm in CUSUM

list_h_sol="300 500 700 1000 1300 1500 1700 2000 2500 3000 3500 4000 4500
5000 5500 6000 6500 7000 7500 8000 8500 9000 9500 10000"
length=50000

for h_sol in ${list_h_sol}
do
    atfa=`dcsloop dcsloop.par h_sol=${h_sol} stream_len=${length} \
	| tail -1 | awk '{print $6}'`
    echo ${h_sol} ${atfa}
done

# End of file
