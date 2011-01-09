#!/bin/sh

# Compare NN-C created using several training data sets obtained from
# different probe signals.

refer=step_r.dat
noise=step_z.dat
#step_n.dat

d2ts step_r.dat step_r.xy.dat 1

for d in stoch step harm pid ; do
  echo "Processing $d ..."
  case "$d" in
    pid)
      ckind="contr_kind=lin"
      ;;
    *)
      ckind="nncontr=${d}/pre.nnc"
      ;;
  esac
  dcsloop dpidsys.par in_r=$refer in_n=$noise $ckind \
    out_u=${d}_u.dat out_e=${d}_e.dat out_ny=${d}_ny.dat

  d2ts ${d}_ny.dat ${d}_ny.xy.dat 1
done

# End of file
