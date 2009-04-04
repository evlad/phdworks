Ky=2.5;
Ty=4;
alpha=1/Ty;
d=exp(-alpha);
kappa=Ky/Ty;
printf("Set point*:\n\tKy=%.3g\n\tDy=%.3g\n", kappa, d);
Kn=0.7;
a=roots([1 -(d+1/d) 1]);
b=roots([1 -(d+1/d+kappa^2/(d*Kn^2)) 1]);
Kf=kappa^2/(Kn^2*d*(b(1)-a(2)));
Df=b(2);
printf("Optimal filter:\n\tKf=%.3g\n\tDf=%.3g\n", Kf, Df);
Emin1=kappa^2/(d*(a(1)-a(2)));
Emin2=kappa^4*b(1)/(Kn^2*d^2*(a(1)-a(2))*(b(1)-a(2))^2);
Emin=Emin1-Emin2;
printf("Emin=%.3g\n", Emin);
