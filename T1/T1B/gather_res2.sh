#!/bin/sh
# $Id: gather_res2.sh,v 1.1 2001-05-12 16:10:13 vlad Exp $

yd_list="1 2 3 4"
nninp=1
nnarch=1
nnplist=nnp_${nninp}+[1-4]_${nnarch}_trace.dat
resfile=nnpres2_${nninp}+x_${nnarch}.dat

cp /dev/null $resfile

for plant in 21 22 23 24 25 26 27 28 29
do
    cd ${plant}
    for ydelay in ${yd_list}
    do
	nnp=nnp_${nninp}+${ydelay}_${nnarch}_trace.dat
	echo 0.${plant#2} ${ydelay} `tail -1 $nnp | awk '{print $8}'` \
	    >>../${resfile}
    done
    cd ..
    echo >>${resfile}
done

# End of file
