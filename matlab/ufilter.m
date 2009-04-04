Kr=1;
Dr=0.8;
Kn=0.1;
Kg=0.25;
Dg=0.75;

N=[Kr -Kr*Dg 0];
D=conv([1 -Dr], [(Kg+Kn) -Kn*Dg]);

N
D
