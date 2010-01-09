#!/bin/sh

# Generate random pairs according to given transfer function

if [ $# = 0 ]
then
    echo "Usage: u_by_tf.sh file.tf [length]"
    return 1
fi

tf="$1"
len="${2:-1000}"
u1="/tmp/u_by_tf_$$_1"
u2="/tmp/u_by_tf_$$_2"

drand $len 0 1 "$tf" >"$u1"
DRAND_SAFE=5 drand $len 0 1 "$tf" >"$u2"

paste "$u1" "$u2" ; rm -f "$u1" "$u2"

# End of file
