#!/bin/sh
# $Id: weight_init.sh,v 1.1 2001-04-15 19:31:26 vlad Exp $

#######################################################################
# ����������� � ���������� ���������������� �������� �������� ��-� �
# ���������� �������� ������� �������������
#######################################################################

# ������ ��������� ���������� ������������� �����
initw_list='0.5 0.4 0.3 0.2 0.1 0.05'

# ������
plant_tf=g3.tf

# �������� ����������: ������� �����������; ������� �����������
nno_list='nno_1+3_1.nn nno_1+3_41.nn nno_1+3_731.nn'

# ����������� ������ ������������� �����������
contr_tf=u.tf

# ����������� ������ ������ � ����������� ������ �������
noise_tf=wn1.tf

# ����� ��������� ����������
learn_len=250

# ����� �������� ����������
test_len=500

# ������ ���������� ��� ������ ��������� ��������� �����
iter_list='0 1 2 3 4 5 6 7 8 9'

# �������� ��������� ��������
export finish_on_value=0.001
export finish_on_grow=50
export finish_max_epoch=400


# Something to protect the same seed in srand()
export DRAND_SAFE=t

##################################################
# Generate data series:
# $1 - series length
# $2 - file suffix (not extension!)
# $3 - plant transfer function file
# $4 - noise transfer function file (opt)
# $5 - input transfer function file (opt)
gen_data_series ()
{
    len=$1
    suffix="$2"
    object_tf="$3"
    noise_tf="$4"
    force_tf="$5"

    # u - control force
    drand ${len} 0 1 ${force_tf} >u_${suffix}.dat

    # y - pure plant output
    dtf ${object_tf} u_${suffix}.dat y_${suffix}.dat

    # n - observation noise
    drand ${len} 0 1 ${noise_tf} >n_${suffix}.dat

    # n+y - noisy plant output
    dsum n_${suffix}.dat y_${suffix}.dat >ny_${suffix}.dat
}

#######################################################################
# ��������� ������
if [ ! -f _data_ok ]
then
    cp /dev/null _data_ok

    gen_data_series ${learn_len} "learn" ${plant_tf} ${noise_tf} ${contr_tf}
    gen_data_series ${test_len} "test" ${plant_tf} ${noise_tf} ${contr_tf}
fi

for nno in ${nno_list}
do
    echo "
@@@ ${nno} @@@"
    date

    nnroot=${nno%.nn}

    mkdir -p ${nnroot}

    cp [nuy]_test.dat ny_test.dat [nuy]_learn.dat ny_learn.dat ${nnroot}

    cd ${nnroot}

    for initw in ${initw_list}
    do
	echo "
*** init weights in range -${initw}..${initw} ***"
	date

	export NA_WEIGHT_INIT_MAX=${initw}

	for iter in ${iter_list}
	do
	    echo "Iteration ${iter}"
	    base=${initw}_${iter}

	    nno_in="nno_${base}.nn"
	    nno_out="nno_${base}_res.nn"
	    nno_trace="nno_trace_${base}.dat"

	    # ���������������� ���� ����
	    ResetNN ../${nno} ${nno_in}

	    # ��������� �������� ��-�
	    echo "# dobjid parameters

# NNO TEACHING
# Input files
in_x = u_learn.dat
in_y = ny_learn.dat

# Output files
nn_y = nn_y_${base}.dat

# NNO TESTING
# Input files
test_in_x = u_test.dat
test_in_y = ny_test.dat

# Output files
test_nn_y = y_test_${base}.dat

# Neural net file
in_nno_file = ${nno_in}
out_nno_file = ${nno_out}

# Tracking learning process:
# LearnME LearnSDE LearnMSE TestME TestSDE TestMSE NormLearnMSE NormTestMSE
trace_file = ${nno_trace}

# Stop learning if...
finish_on_value=${finish_on_value}
finish_on_grow=${finish_on_grow}
finish_max_epoch=${finish_max_epoch}

# Learning algorithm setup
eta = 0.01
eta_output = 0.001
alpha = 0.0
" >nno_dobjid_${base}.par

	    dobjid nno_dobjid_${base}.par \
		</dev/null >nno_training_${base}.log && \
	    mv dobjid.log nno_dobjid_${base}.log
	done
    done

    cd ..
done

# End of file
