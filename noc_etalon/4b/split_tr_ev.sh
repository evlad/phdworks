#!/bin/sh

# Split series into training and evaluation parts in proportion 4/1

split_parts ()
{
    in_file=$1
    tr_file=$2
    ev_file=$3

    len=`wc -l ${in_file} | awk '{print $1}'`
    ev_len=`expr $len / 5`
    tr_len=`expr $len - ${ev_len}`

    head -${ev_len} ${in_file} >${ev_file}
    tail -${tr_len} ${in_file} >${tr_file}
}


split_parts_tail ()
{
    echo "split_parts_tail: $*"
    in_file=$1
    tail_len=$2
    tr_file=$3
    ev_file=$4

    tail -${tail_len} ${in_file} >/tmp/split_tr_ev_$$
    split_parts /tmp/split_tr_ev_$$ $3 $4
    rm -f /tmp/split_tr_ev_$$
}


split_parts_tail r_out.dat 500 ../4b_0tr/r.dat  ../4b_0ev/r.dat
split_parts_tail ny.dat    500 ../4b_0tr/ny.dat ../4b_0ev/ny.dat
split_parts_tail u.dat     500 ../4b_0tr/u.dat  ../4b_0ev/u.dat
split_parts_tail e.dat     500 ../4b_0tr/e.dat  ../4b_0ev/e.dat

split_parts_tail y.dat     500 ../4b_0tr/y.dat  ../4b_0ev/y.dat
split_parts_tail n_out.dat 500 ../4b_0tr/n.dat  ../4b_0ev/n.dat

 # End of file
