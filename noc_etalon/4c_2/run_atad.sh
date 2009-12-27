#!/bin/sh

# Run experiment for average time of false alarm in CUSUM

list_h_sol="0.5 0.75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 4 5 6 7 8 9 10"

for h_sol in ${list_h_sol}
do
    atad2=`dcsloop dcsloop.par sigma1=0.3 h_sol=${h_sol} \
	| tail -1 | awk '{print $6}'`
    atad3=`dcsloop dcsloop.par sigma1=0.45 h_sol=${h_sol} \
	| tail -1 | awk '{print $6}'`
    atad4=`dcsloop dcsloop.par sigma1=0.6 h_sol=${h_sol} \
	| tail -1 | awk '{print $6}'`
    atad5=`dcsloop dcsloop.par sigma1=0.75 h_sol=${h_sol} \
	| tail -1 | awk '{print $6}'`
    echo ${h_sol} ${atad2} ${atad3} ${atad4} ${atad5}
done

# End of file
