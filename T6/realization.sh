#!/bin/sh
# $Id: realization.sh,v 1.1 2001-04-15 19:56:33 vlad Exp $

#######################################################################
# Эксперимент с выяснением чувствительности обучения НС-О к реализации
# обучающей выборки
#######################################################################

# Объект
plant_tf=g3.tf

# Варианты нейросетей: простая архитектура; средняя архитектура;
# сложная архитектура
nno_list='nno_1+3_1.nn nno_1+3_41.nn nno_1+3_731.nn'

# Формирующий фильтр регулирующего воздействия
if [ "${contr_tf}" = "" ]
then
    contr_tf=u.tf
fi

# Формирующий фильтр помехи в наблюдаемом выходе объекта
noise_tf=wn1.tf

# Длина обучающей реализации
if [ "${learn_len}" = "" ]
then
    learn_len=500
fi

# Длина тестовой реализации
test_len=500

# Список реализаций 
if [ "${iter_list}" = "" ]
then
    iter_list='0 1 2 3 4 5 6 7 8 9'
fi

# Заданные параметры обучения
export finish_on_value=0.001
export finish_on_grow=20
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
    local len=$1
    local suffix="$2"
    local object_tf="$3"
    local noise_tf="$4"
    local force_tf="$5"

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
# Генерация тестовой выборки
gen_data_series ${test_len} "test" ${plant_tf} ${noise_tf} ${contr_tf}

for nno in ${nno_list}
do
    echo "
@@@ ${nno} @@@"
    date

    nnroot=${nno%.nn}

    mkdir -p ${nnroot}

    cp [nuy]_test.dat ny_test.dat ${nnroot}

    cd ${nnroot}
    dir=..

    for iter in ${iter_list}
    do
	echo "
*** Realization ${iter} ***"
	date

	base="${iter}_n${learn_len}"
	gen_data_series ${learn_len} "learn_${base}" ${dir}/${plant_tf} \
	    ${dir}/${noise_tf} ${dir}/${contr_tf}

	nno_in=${dir}/${nno}
	nno_out="nno_${base}_res.nn"
	nno_trace="nno_trace_${base}.dat"

	# Параметры обучения НС-О
	echo "# dobjid parameters

# NNO TEACHING
# Input files
in_x = u_learn_${base}.dat
in_y = ny_learn_${base}.dat

# Output files
nn_y = nn_y_${base}.dat

# NNO TESTING
# Input files
test_in_x = ${dir}/u_test.dat
test_in_y = ${dir}/ny_test.dat

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

	dobjid nno_dobjid_${base}.par </dev/null >nno_training_${base}.log && \
	    mv dobjid.log nno_dobjid_${base}.log
    done

    cd ${dir}
done

# End of file
