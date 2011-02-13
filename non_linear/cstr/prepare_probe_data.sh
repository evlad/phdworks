#!/bin/sh

# Take starting point to be close to initial conditions
#                                    __________ 
# initial 0.486938 2.002389 1.730673 363.700000 357.706961
Tinit=`grep initial model_proof/cstrplant.cof | head -1 | awk '{printf "%g\n", $5}'`
echo "Tinit=$Tinit"

LearnLen=2000
TestLen=1000

#
# Prepare learning data
#

# Replace level of the first step by Tinit
drandmea $LearnLen 60 300 352 366 >/tmp/drandmea.dat
Told=`head -1 /tmp/drandmea.dat`
sed "s/^$Told\$/$Tinit/" /tmp/drandmea.dat >r_learn.dat

drand $LearnLen 0 0 >n_learn.dat

FileCvt r_learn.dat r_learn.bis
FileCvt n_learn.dat n_learn.bis

# Run modeling
dcsloop origsys.par in_r=r_learn.bis in_n=n_learn.bis \
  out_u=u_learn.dat out_e=e_learn.dat out_ny=ny_learn.dat
mv cstr_out.dat cstr_learn.dat

FileCvt u_learn.dat u_learn.bis
FileCvt e_learn.dat e_learn.bis
FileCvt ny_learn.dat ny_learn.bis

#
# Prepare test data
#

# Replace level of the first step by Tinit
drandmea $TestLen 60 300 352 366 >/tmp/drandmea.dat
Told=`head -1 /tmp/drandmea.dat`
sed "s/^$Told\$/$Tinit/" /tmp/drandmea.dat >r_test.dat

drand $TestLen 0 0 >n_test.dat

FileCvt r_test.dat r_test.bis
FileCvt n_test.dat n_test.bis

# Run modeling
dcsloop origsys.par in_r=r_test.bis in_n=n_test.bis \
  out_u=u_test.dat out_e=e_test.dat out_ny=ny_test.dat
mv cstr_out.dat cstr_test.dat

FileCvt u_test.dat u_test.bis
FileCvt e_test.dat e_test.bis
FileCvt ny_test.dat ny_test.bis

# End of file
