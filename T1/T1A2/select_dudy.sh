#!/bin/sh

# $Id: select_dudy.sh,v 1.1 2001-12-20 20:56:54 vlad Exp $

#######################################################################
# Эксперимент с выяснением влияния памяти на входах НС-О на качество
# обучения НС-О
#######################################################################

# Объект с запаздыванием
plant_tf=$1
#g5_5.tf

# Варианты нейросетей:
#  1) u(k), y(k)							1+1
# 2) u(k), u(k-1), y(k-1)					2+1
# 3) u(k), u(k-1), u(k-2), y(k-2)				3+1
# 4) u(k), u(k-1), u(k-2), u(k-3), y(k-3)			4+1
#  5) u(k), y(k), y(k-1)						1+2
#  6) u(k), u(k-1), y(k), y(k-1)					2+2
# 7) u(k), u(k-1), u(k-2), y(k-1), y(k-2)			3+2
# 8) u(k), u(k-1), u(k-2), u(k-3), y(k-2), y(k-3)		4+2
#  9) u(k), y(k), y(k-1), y(k-2)					1+3
#  10) u(k), u(k-1), y(k), y(k-1), y(k-2)				2+3
#  11) u(k), u(k-1), u(k-2), y(k), y(k-1), y(k-2)			3+3
# 12) u(k), u(k-1), u(k-2), u(k-3), y(k-1), y(k-2), y(k-3)	4+3
#  13) u(k), y(k), y(k-1), y(k-2), y(k-3)				1+4
#  14) u(k), u(k-1), y(k), y(k-1), y(k-2), y(k-3)			2+4
#  15) u(k), u(k-1), u(k-2), y(k), y(k-1), y(k-2), y(k-3)		3+4
#  16) u(k), u(k-1), u(k-2), u(k-3), y(k), y(k-1), y(k-2), y(k-3)	4+4

nnarch=831
nnp_list=nnp_[1234]+[1234]_${nnarch}.nn


# Формирующий фильтр регулирующего воздействия
force_tf=${PWD}/w1.tf

# Формирующий фильтр помехи в наблюдаемом выходе объекта
noise_tf=${PWD}/w0.1.tf

# Длина обучающей реализации
learn_len=250

# Длина тестовой реализации
test_len=500

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
    FileCvt u_${suffix}.dat u_${suffix}.bis && rm u_${suffix}.dat

    # y - pure plant output
    dtf ${object_tf} u_${suffix}.bis y_${suffix}.bis

    # n - observation noise
    drand ${len} 0 1 ${noise_tf} >n_${suffix}.dat
    FileCvt n_${suffix}.dat n_${suffix}.bis && rm n_${suffix}.dat

    # n+y - noisy plant output
    dsum n_${suffix}.bis y_${suffix}.bis >ny_${suffix}.dat
    FileCvt ny_${suffix}.dat ny_${suffix}.bis && rm ny_${suffix}.dat
}

#######################################################################
# Генерация данных
if [ ! -f _data_ok ]
then
    cp /dev/null _data_ok

    gen_data_series ${learn_len} "learn" ${plant_tf} ${noise_tf} ${contr_tf}
    gen_data_series ${test_len} "test" ${plant_tf} ${noise_tf} ${contr_tf}
fi

for nnp in ${nnp_list}
do
    echo "
@@@ ${nnp} @@@"
    date

    nnroot=${nnp%.nn}

    mkdir -p ${nnroot}

    cp [nuy]_test.bis ny_test.bis [nuy]_learn.bis ny_learn.bis ${nnroot}
    cp ${nnp} ${nnroot}

    cd ${nnroot}

    nnp_in=${nnroot}.nn
    nnp_out=${nnroot}_res.nn
    nnp_trace=${nnroot}_trace.dat

    # prepare parameters
    echo "# dplantid parameters

# NNP TEACHING
# Input files
in_u = u_learn.bis
in_y = ny_learn.bis

# Output files
nn_y = ${nnroot}_y.bis

# NNP TESTING
# Input files
test_in_u = u_test.bis
test_in_y = ny_test.bis

# Output files
test_nn_y = ${nnroot}_y_test.bis

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

    # return to main directory
    cd ..
done

echo "
Done."

# End of file
