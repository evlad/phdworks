plot [dk=3:0.50] a7(0.15,dk,phi,r,f) t "{/Symbol=a}_k=0.15" w l, \
		 a7(0.10,dk,phi,r,f) t "{/Symbol=a}_k=0.10" w l, \
		 a7(0.05,dk,phi,r,f) t "{/Symbol=a}_k=0.05" w l, \
		 a7(0.00,dk,phi,r,f) t "{/Symbol=a}_k=0.00" w l, \
		 a7(-0.05,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.05" w l, \
		 a7(-0.10,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.10" w l, \
		 a7(-0.15,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.15" w l
set xlabel "d_k, m"
set ylabel "{/Symbol=a}_{k+1}, m"
set terminal postscript landscape enhanced
set output 'a7_dk.eps'
replot
set terminal x11
