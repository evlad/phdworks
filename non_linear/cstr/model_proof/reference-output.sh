#!/bin/sh

dcsloop pidsys.par
paste steps.dat cstr_out.dat|awk '{print $2, $1}' >refer_t.dat
