#!/bin/sh
# $Id: many_learn_len.sh,v 1.1 2001-04-15 19:56:33 vlad Exp $

export iter_list='0 1 2 3 4 5 6 7 8 9'
export contr_tf=u.tf

#export iter_list='0 1 2 3 4'
#export contr_tf=u_c2.tf

for learn_len in 500 250 100 50
do
    export learn_len
    echo "
### learn_len=${learn_len} ###
"
    ./realization.sh
done

# End of file
