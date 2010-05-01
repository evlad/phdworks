#!/bin/sh

head -450 tdg_u.dat >u1.dat
head -450 tdg_ny.dat >ny1.dat

tail -110 tdg_u.dat >u2.dat
tail -110 tdg_ny.dat >ny2.dat

# End of file
