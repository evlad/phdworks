#!/bin/sh

paste r_learn.dat cstr_learn.dat|awk '{print $2, $1}' >r_learn_t.dat
paste r_test.dat cstr_test.dat|awk '{print $2, $1}' >r_test_t.dat
