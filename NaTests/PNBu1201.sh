#!/bin/sh

# Set of tests for basic NaPNBus1i2o functions
TESTNAME=PNBu1201

TESTCASES=${*:-1 2 3 4}
echo " => ${TESTNAME} - test cases: ${TESTCASES}"

eval export ${TESTNAME}_printout=ipm

if [ ! -x ${TESTNAME} ] ; then
  echo "Executable ${TESTNAME} is not found!"
  exit 100
fi

for tc in ${TESTCASES} ; do
  echo -n " ==> test case ${tc}: "
  ./${TESTNAME} ${tc}
  rc=$?
  [ -f ${TESTNAME}.log ] && mv ${TESTNAME}.log ${TESTNAME}-${tc}.log
  [ -f ${TESTNAME}.map ] && mv ${TESTNAME}.map ${TESTNAME}-${tc}.map
  if [ $rc = 0 ] ; then
    if [ ! -f ${TESTNAME}-${tc}_output1.dat \
      -o ! -f ${TESTNAME}-${tc}_output2.dat ] ; then
      mv -f ${TESTNAME}_output1.dat ${TESTNAME}-${tc}_output1.dat
      mv -f ${TESTNAME}_output2.dat ${TESTNAME}-${tc}_output2.dat
      echo "CREATED, check output ${TESTNAME}-${tc}_output1.dat ${TESTNAME}-${tc}_output2.dat"
    else
      echo -n "ok, "
      if diff --ignore-all-space >${TESTNAME}-${tc}_1.diff \
	${TESTNAME}-${tc}_output1.dat ${TESTNAME}_output1.dat \
	&& \
	diff --ignore-all-space >${TESTNAME}-${tc}_2.diff \
	${TESTNAME}-${tc}_output2.dat ${TESTNAME}_output2.dat ; then
	echo "passed"
	rm -f ${TESTNAME}-${tc}_[12].diff
      else
	echo "FAILED, see ${TESTNAME}-${tc}_1.diff, ${TESTNAME}-${tc}_2.diff"
      fi
    fi
  else
    echo "failed with code ${rc}, see ${TESTNAME}-${tc}.log"
  fi
done

# End of file
