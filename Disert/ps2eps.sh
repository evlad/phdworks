#!/bin/sh

# List of *.ps files to convert
for ps ; do
  fn=${ps%.ps}
  if [ "$fn" = "$ps" ] ; then
    echo "Skip $ps ..."
  else
    eps=$fn.eps
    echo "Processing $ps to $eps ..."
    sed 's/^!%PS.*$/%!PS-Adobe-3.0 EPSF-3.0/g' $ps >$eps
  fi
done
