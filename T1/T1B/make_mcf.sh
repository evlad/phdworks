#!/bin/sh

plant_list=plant_2[1-9].tf

for plant in ${plant_list}
do
    root=${plant%.tf}
    root=${root#plant_}
    echo $root
    dtf $plant u.dat y_${root}.dat
    dcorr 20 u.dat y_${root}.dat >mcf_${root}.dat
done
