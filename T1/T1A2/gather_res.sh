#!/bin/sh
# $Id: gather_res.sh,v 1.1 2001-12-20 20:56:54 vlad Exp $

d=$1
nnarch=831
resfile=${PWD}/nnpres_${d}_Du+Dy_${nnarch}.dat

cp /dev/null ${resfile}

for Du in 1 2 3 4
do
    for Dy in 1 2 3 4
    do
	nnroot=nnp_${Du}+${Dy}_${nnarch}
	nntrace=${nnroot}_trace.dat
	#cd ${nnroot}

	echo ${Du} ${Dy} `tail -1 $nnroot/$nntrace | awk '{print $8}'` \
	    >>${resfile}

	#cd ..
    done
    echo >>${resfile}
done

# End of file
