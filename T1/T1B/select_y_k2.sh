#!/bin/sh
# $Id: select_y_k2.sh,v 1.1 2001-05-12 16:10:14 vlad Exp $

# Something to protect the same seed in srand()
export DRAND_SAFE=t

##################################################
# Generate data series:
# $1 - series length
# $2 - file suffix (not extension!)
# $3 - plant transfer function file
# $4 - noise transfer function file
# $5 - input transfer function file (opt)
gen_data_series ()
{
    len=$1
    suffix="$2"
    plant_tf="$3"
    noise_tf="$4"
    force_tf="$5"

    # u - control force
    drand ${len} 0 1 ${force_tf} >u_${suffix}.dat

    # y - pure plant output
    dtf ${plant_tf} u_${suffix}.dat y_${suffix}.dat

    # n - observation noise
    drand ${len} 0 1 >wn_${suffix}.dat
    dtf ${noise_tf} wn_${suffix}.dat n_${suffix}.dat

    # n+y - noisy plant output
    dsum n_${suffix}.dat y_${suffix}.dat >ny_${suffix}.dat
}

##################################################
# BEGIN: Generate data

noise_tf=${PWD}/w0.1.tf
force_tf=${PWD}/w1.tf

# series lengths
learn_len=250
test_len=500

# END: Generate data
##################################################


nnp_list=nnp_2+[1-4]_531.nn
plant_list=plant_[1-9].tf

# For each plant...
for plant in ${plant_list}
do
    plantroot=${plant%.tf}
    plantroot=${plantroot#plant_}

    # create subdirectory for results
    if [ ! -d "${plantroot}" ]
    then
	mkdir ${plantroot}
    fi

    # Copy all neural nets
    cp nnp_*.nn ${plantroot}

    # Copy plant transfer function
    cp ${plant} ${plantroot}/plant.tf

    cd ${plantroot}

    echo "**************************************************
*******             ${plant}             *******
**************************************************"

    date

    # Learning data series
    #gen_data_series ${learn_len} "learn" plant.tf ${noise_tf} ${force_tf}

    # Test data series
    #gen_data_series ${test_len} "test" plant.tf ${noise_tf} ${force_tf}

    # for each neural net
    for nnp in ${nnp_list}
    do
    echo "
***  ${nnp}  ***
"

	nnroot=${nnp%.nn}
	nnp_in=${nnroot}.nn
	nnp_out=${nnroot}_res.nn
	nnp_trace=${nnroot}_trace.dat

	# prepare parameters
	echo "# dplantid parameters

# NNP TEACHING
# Input files
in_u = u_learn.dat
in_y = ny_learn.dat

# Output files
nn_y = ${nnroot}_y.dat

# NNP TESTING
# Input files
test_in_u = u_test.dat
test_in_y = ny_test.dat

# Output files
test_nn_y = ${nnroot}_y_test.dat

# Neural net file
in_nnp_file = ${nnp_in}
out_nnp_file = ${nnp_out}

# Tracking learning process:
# LearnME LearnSDE LearnMSE TestME TestSDE TestMSE 
trace_file = ${nnp_trace}

# Stop learning if...
finish_on_value=0.00009
finish_on_grow=20
finish_max_epoch=500

# Learning algorithm setup
eta = 0.01
eta_output = 0.001
alpha = 0.0
" >${nnroot}.par

	dplantid ${nnroot}.par </dev/null >${nnroot}_training.log && \
	    mv dplantid.log ${nnroot}_dplantid.log

    done

    # return to main directory
    cd ..

done

echo "
Done."

# End of file
