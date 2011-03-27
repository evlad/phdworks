#!/bin/sh

dcsloop.new pidsys.par
dcsloop.new nncsys.par
paste steps.dat cstr_out.dat|awk '$2!=""&&$1!=""{print $2, $1}' >refer_t.dat
paste pid_ny.dat cstr_out.dat|awk '$2!=""&&$1!=""{print $2, $1}' >pid_t_ny.dat
paste nnc_ny.dat cstr_out.dat|awk '$2!=""&&$1!=""{print $2, $1}' >nnc_t_ny.dat
paste pid_u.dat cstr_out.dat|awk '$2!=""&&$1!=""{print $2, $1}' >pid_t_u.dat
paste nnc_u.dat cstr_out.dat|awk '$2!=""&&$1!=""{print $2, $1}' >nnc_t_u.dat
