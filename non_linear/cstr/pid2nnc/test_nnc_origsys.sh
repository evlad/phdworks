#!/bin/sh

# Mode:
nnc="nncontr=nnc_e5r1_95_1.nn"

dcsloop.new origsys.par contr_kind=nnc $nnc \
  linplant_tf=../model_proof/cstrplant.cof \
  lincontr_tf=../model_proof/pid.cof \
  in_r=r_learn.bis in_n=n_learn.bis \
  out_u=nn_u_learn.dat out_e=nn_e_learn.dat out_ny=nn_ny_learn.dat

dcsloop.new origsys.par contr_kind=nnc $nnc \
  linplant_tf=../model_proof/cstrplant.cof \
  lincontr_tf=../model_proof/pid.cof \
  in_r=r_test.bis in_n=n_test.bis \
  out_u=nn_u_test.dat out_e=nn_e_test.dat out_ny=nn_ny_test.dat
