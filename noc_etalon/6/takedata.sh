#!/bin/sh

start=1510
tr_len=1000
ev_len=300

trtotal=`expr $start + ${tr_len}`
evtotal=`expr $trtotal + ${ev_len}`

head -n $trtotal ../5a/u.dat | tail -n ${tr_len} >u_tr.dat
head -n $trtotal ../5a/ny.dat | tail -n ${tr_len} >ny_tr.dat

head -n $evtotal ../5a/u.dat | tail -n ${ev_len} >u_ev.dat
head -n $evtotal ../5a/ny.dat | tail -n ${ev_len} >ny_ev.dat

FileCvt u_tr.dat u_tr.bis
FileCvt ny_tr.dat ny_tr.bis
FileCvt u_ev.dat u_ev.bis
FileCvt ny_ev.dat ny_ev.bis

# End of file
