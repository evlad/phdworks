plot [dk=0.55:0] a11(0.03,dk,phi,r,f) t "{/Symbol=a}_k=0.03" w l, \
		 a11(0.02,dk,phi,r,f) t "{/Symbol=a}_k=0.02" w l, \
		 a11(0.01,dk,phi,r,f) t "{/Symbol=a}_k=0.01" w l, \
		 a11(0.00,dk,phi,r,f) t "{/Symbol=a}_k=0.00" w l, \
		 a11(-0.01,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.01" w l, \
		 a11(-0.02,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.02" w l, \
		 a11(-0.03,dk,phi,r,f) t "{/Symbol=a}_k={/Symbol=-}0.03" w l
set xlabel "d_k, m"
set ylabel "{/Symbol=a}_{k+1}, m"
set terminal postscript landscape enhanced
set output 'a11_dk.eps'
replot
set terminal x11
