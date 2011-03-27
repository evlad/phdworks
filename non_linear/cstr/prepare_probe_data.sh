#!/bin/sh

# Take starting point to be close to initial conditions
echo "*** Take initial conditions for model_proof/cstrplant.cof:"
# initial 0.486938 2.002389 1.730673 363.700000 357.706961
Tinit=`grep initial model_proof/cstrplant.cof | head -1 | awk '{printf "%g\n", $5}'`
echo "*** Tinit=$Tinit"

learn_len=5000
test_len=1000
check_len=3000

# For every series type
for st in learn test check ; do
  len=$(eval echo \$${st}_len)
  recalc=""

  # Prepare input series
  if [ ! -s r_${st}.dat ] ; then
    echo "*** Generate r_${st}.dat and n_${st}.dat ($len samples)"

    # Replace level of the first step by Tinit
    drandmea $len 60 300 352 366 >/tmp/drandmea.dat
    Told=`head -1 /tmp/drandmea.dat`
    sed "s/^$Told\$/$Tinit/" /tmp/drandmea.dat >r_${st}.dat

    DRAND_SAFE=1 drand $len 0 0 >n_${st}.dat

    FileCvt r_${st}.dat r_${st}.bis
    FileCvt n_${st}.dat n_${st}.bis

    recalc="yes"
  fi

  # Run modeling
  if [ "$recalc" = yes -o \
    ! -s u_${st}.dat -o ! -s e_${st}.dat -o ! -s ny_${st}.dat ] ; then
    echo "*** Modeling for u_${st}.dat, e_${st}.dat, ny_${st}.dat ..."
    dcsloop origsys.par in_r=r_${st}.bis in_n=n_${st}.bis \
      out_u=u_${st}.dat out_e=e_${st}.dat out_ny=ny_${st}.dat
    mv cstr_out.dat cstr_${st}.dat

    paste r_${st}.dat e_${st}.dat u_${st}.dat|head -n -1 >reu_${st}.dat

    FileCvt u_${st}.dat u_${st}.bis
    FileCvt e_${st}.dat e_${st}.bis
    FileCvt ny_${st}.dat ny_${st}.bis
  fi
done


# End of file
