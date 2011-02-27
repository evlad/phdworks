#!/bin/sh

# Set of tests for basic NaPNDelay functions
TESTNAME=PNDely01

TESTCASES=${*:-1 2 3 4 5 6 7}
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
    if [ ! -f ${TESTNAME}-${tc}_output.dat ] ; then
      mv ${TESTNAME}_output.dat ${TESTNAME}-${tc}_output.dat
      echo "CREATED, check output ${TESTNAME}-${tc}_output.dat"
    else
      echo -n "ok, "
      if diff --ignore-all-space \
	${TESTNAME}-${tc}_output.dat ${TESTNAME}_output.dat \
	>${TESTNAME}-${tc}.diff ; then
	echo "passed"
	rm -f ${TESTNAME}-${tc}.diff
      else
	echo "FAILED, see ${TESTNAME}-${tc}.diff"
      fi
    fi
  else
    echo "failed with code ${rc}, see ${TESTNAME}-${tc}.log"
  fi
done

# End of file
