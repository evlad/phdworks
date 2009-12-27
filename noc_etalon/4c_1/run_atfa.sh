#!/bin/sh

# Run experiment for average time of false alarm in CUSUM

list_h_sol="0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 4 5 6 7 8 9 10"
# 11 12 13 14 15"
length=100000

for h_sol in ${list_h_sol}
do
    atfa2=`dcsloop dcsloop.par sigma1=0.3 h_sol=${h_sol} stream_len=${length} \
	| tail -1 | awk '{print $6}'`
    atfa3=`dcsloop dcsloop.par sigma1=0.45 h_sol=${h_sol} stream_len=${length} \
	| tail -1 | awk '{print $6}'`
    atfa4=`dcsloop dcsloop.par sigma1=0.6 h_sol=${h_sol} stream_len=${length} \
	| tail -1 | awk '{print $6}'`
    atfa5=`dcsloop dcsloop.par sigma1=0.75 h_sol=${h_sol} stream_len=${length} \
	| tail -1 | awk '{print $6}'`
    echo ${h_sol} ${atfa2} ${atfa3} ${atfa4} ${atfa5}
done

# End of file
