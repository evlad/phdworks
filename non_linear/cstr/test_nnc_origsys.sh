#!/bin/sh

dcsloop origsys.par nnc_mode=e+r contr_kind=nnc nncontr=nnc_er_1.nn \
  in_r=r_learn.bis in_n=n_learn.bis \
  out_u=nn_u_learn.dat out_e=nn_e_learn.dat out_ny=nn_ny_learn.dat

dcsloop origsys.par nnc_mode=e+r contr_kind=nnc nncontr=nnc_er_1.nn \
  in_r=r_test.bis in_n=n_test.bis \
  out_u=nn_u_test.dat out_e=nn_e_test.dat out_ny=nn_ny_test.dat
