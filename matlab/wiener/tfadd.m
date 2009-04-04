%TFSUB Вычисление суммы двух линейных систем
%      n1       n2       n1*d2 + n2*d1
% w1 = --  w2 = --  wr = -------------
%      d1       d2           d1*d2
% где n1,n2,d1,d2 - полиномы

function wr = tfadd(w1,w2)

  [n1,d1] = tfdata(w1,'v');
  [n2,d2] = tfdata(w2,'v');

  n = padd(conv(n1,d2), conv(n2,d1));
  d = conv(d1, d2);

  [nr,dr] = pqnorm(n,d);
  wr = tf(nr,dr);

% End of file
