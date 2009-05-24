#!/bin/bash

echo "*** Create evaluation/testing data set ***"
cd 0ev
dcsloop dcsloop.par stream_len=200

echo "*** Create training data set ***"
cd ../0tr
dcsloop dcsloop.par stream_len=1000

echo "*** NN plant identification out of loop ***"
cd ../1
MakeNN nnp_ini.nn Plant 1 2 1 2 0 0 1 5
dplantid dplantid.par in_nnp_file=nnp_ini.nn out_nnp_file=nnp_res.nn
gnuplot report.plt

echo "*** NN controller training to bad PID out of loop ***"
cd ../2
MakeNN nnc_ini.nn Controller 2 1 1 0 0 0 1 5
dcontrp dcontrp.par in_nnc_file=nnc_ini.nn out_nnc_file=nnc_pre.nn
gnuplot report.plt

echo "*** NN controller training optimally in the loop ***"
cd ../3
dcontrf dcontrf.par stream_len=50000 nnc_auf=50 \
    in_nnp_file=../1/nnp_res.nn \
    in_nnc_file=../2/nnc_pre.nn \
    out_nnc_file=nnc_res.nn
gnuplot report.plt

echo "*** NN controller evaluation in the loop ***"
cd ../4
dcsloop dcsloop.par stream_len=1000 \
    nncontr=../3/nnc_res.nn
gnuplot report.plt

cd ..
echo "*** Done ***"

# End of file
