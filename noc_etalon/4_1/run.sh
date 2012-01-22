#!/bin/bash

# Test WOC and NOC on different harmonic signals

L=1000
A=2

cp /dev/null result.dat

for t in 4 6 8 10 11 12 13 14 15 16 17 18 19 20 25 30 35 50 60 70 80 90 100 ; do
  mkdir -p $t
  cd $t
  echo "Calculating for T=$t ..."
  Lr=`wc -l r.dat 2>/dev/null | awk '{print $1}'`
  #echo "Lr=$Lr"
  if [ ${Lr:-0} -lt $L ] ; then
    dsin $L $t >r0.dat
    dmult $A r0.dat >r.dat
    rm -f r0.dat
  fi
  Ln=`wc -l ../n.dat 2>/dev/null | awk '{print $1}'`
  #echo "Ln=$Ln"
  if [ ${Ln:-0} -lt $L ] ; then
    drand $L 0 1 ../../noise.tf >../n.dat
  fi
  echo ">> WOC ..."
  dcsloop ../dcsloop.par contr_kind=lin input_kind=file \
    linplant_tf=../../plant.tf lincontr_tf=../../woc.tf \
    in_r=r.dat in_n=../n.dat out_u=u_woc.dat out_e=e_woc.dat \
    out_y=y_woc.dat out_ny=ny_woc.dat >/dev/null 2>&1
  wocstat=`StatAn e_woc.dat | tail -1`
  m0=`echo $wocstat | awk '{print $1}'`
  m0="${m0#-*}"
  m9=`echo $wocstat | awk '{print $2}'`
  m9="${m9#-*}"
  if [[ $m0 < $m9 ]] ; then
    wocam=$m9
  else
    wocam=$m0
  fi
  wocse=`echo $wocstat | awk '{print $4}'`
  echo ">> NOC ..."
  dcsloop ../dcsloop.par contr_kind=nnc input_kind=file \
    linplant_tf=../../plant.tf nncontr=../../3/res.nnc \
    in_r=r.dat in_n=../n.dat out_u=u_noc.dat out_e=e_noc.dat \
    out_y=y_noc.dat out_ny=ny_noc.dat >/dev/null 2>&1
  nocstat=`StatAn e_noc.dat | tail -1`
  m0=`echo $nocstat | awk '{print $1}'`
  m0="${m0#-*}"
  m9=`echo $nocstat | awk '{print $2}'`
  m9="${m9#-*}"
  if [[ $m0 < $m9 ]] ; then
    nocam=$m9
  else
    nocam=$m0
  fi
  nocse=`echo $nocstat | awk '{print $4}'`
  cd ..

  echo "$t $wocam $wocse $nocam $nocse" >>result.dat
done

# End of file
