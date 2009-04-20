#!/bin/bash

function one_test ()
{
    name=$1
    shift
    dcsloop ../dcsloop.par $* \
	out_u=${name}_u.dat out_e=${name}_e.dat out_ny=${name}_ny.dat
    echo -n "$d	" >>../stat_${name}.dat
    StatAn ${name}_e.dat | tail -1 >>../stat_${name}.dat
}

rm -f stat_pidbad.dat stat_pid.dat stat_woc.dat stat_nnc.dat

for d in `ls -F | sort -n | grep / | sed 's!/!!g'`
do
    echo "******************"
    echo "*** Test in $d ***"
    echo "******************"
    cd $d

    echo ">>> pid_bad <<<"
    one_test pidbad contr_kind=lin lincontr_tf=../../pid_bad.tf

    echo ">>> pid <<<"
    one_test pid contr_kind=lin lincontr_tf=../../pid.tf

    echo ">>> woc <<<"
    one_test woc contr_kind=lin lincontr_tf=../../woc.tf

    echo ">>> nnc <<<"
    one_test nnc contr_kind=nnc nncontr=../../3/nnc_res.nn

    cd ..
done

gnuplot report_mse.plt

# End of file
