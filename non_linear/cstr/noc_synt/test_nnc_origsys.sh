#!/bin/sh

dcsloop.new ../pid2nnc/origsys.par contr_kind=lin \
  linplant_tf=../model_proof/cstrplant.cof \
  lincontr_tf=../model_proof/pid.cof \
  in_r=../pid2nnc/r_learn.bis in_n=../pid2nnc/n_learn.bis \
  out_u=nn_u_learn_0.dat out_e=nn_e_learn_0.dat out_ny=nn_ny_learn_0.dat

dcsloop.new ../pid2nnc/origsys.par contr_kind=nnc nncontr=../pid2nnc/nnc_e5r1_95_1.nn \
  linplant_tf=../model_proof/cstrplant.cof \
  lincontr_tf=../model_proof/pid.cof \
  in_r=../pid2nnc/r_learn.bis in_n=../pid2nnc/n_learn.bis \
  out_u=nn_u_learn_1.dat out_e=nn_e_learn_1.dat out_ny=nn_ny_learn_1.dat

dcsloop.new ../pid2nnc/origsys.par contr_kind=nnc nncontr=nnc_e5r1_95_2.nn \
  linplant_tf=../model_proof/cstrplant.cof \
  lincontr_tf=../model_proof/pid.cof \
  in_r=../pid2nnc/r_learn.bis in_n=../pid2nnc/n_learn.bis \
  out_u=nn_u_learn_2.dat out_e=nn_e_learn_2.dat out_ny=nn_ny_learn_2.dat
