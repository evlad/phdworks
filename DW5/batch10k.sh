#!/bin/sh

M=30
N=10000
X=10k

rm mse${X}.dat mse${X}_.dat
I=0

while [ "$I" != "$M" ]
do
    echo "$I"
    I=`expr $I + 1`

    DRAND_SAFE=t drand ${N} 0 1 signal.tf >signal${X}_${I}.dat
    mv drand.log drand_signal${X}_${I}.log
    DRAND_SAFE=t drand ${N} 0 1 noise.tf >noise${X}_${I}.dat
    mv drand.log drand_noise${X}_${I}.log
    dwtest wiener.tf signal${X}_${I}.dat noise${X}_${I}.dat \
	out${X}_${I}.dat in${X}_${I}.dat |\
	tail -1 | awk -F = '{print $2}' >>mse${X}_.dat
    dmse signal${X}_${I}.dat out${X}_${I}.dat >>mse${X}.dat
done

StatAn mse${X}.dat

# End of file
