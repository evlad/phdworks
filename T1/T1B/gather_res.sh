#!/bin/sh
# $Id: gather_res.sh,v 1.1 2001-05-12 16:10:13 vlad Exp $

yd_list="1 2 3 4"
nninp=2
nnarch=531
nnplist=nnp_${nninp}+[1-4]_${nnarch}_trace.dat
resfile=nnpres_${nninp}+x_${nnarch}.dat

cp /dev/null $resfile

for plant in 1 2 3 4 5 6 7 8 9
do
    cd ${plant}
    for ydelay in ${yd_list}
    do
	nnp=nnp_${nninp}+${ydelay}_${nnarch}_trace.dat
	echo 0.${plant} ${ydelay} `tail -1 $nnp | awk '{print $8}'` \
	    >>../${resfile}
    done
    cd ..
    echo >>${resfile}
done

# End of file
