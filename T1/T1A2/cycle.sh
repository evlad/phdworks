#!/bin/sh

for Gdelay in 6 7 8 9
do
    echo "~~~ Gdelay=0.${Gdelay} ~~~"
    rm -f _data_ok
    ./select_u_k.sh g5_${Gdelay}.tf
    mkdir ${Gdelay}
    mv nnp_[1-4]+[1-4]_831 ${Gdelay}
done

# End of file
