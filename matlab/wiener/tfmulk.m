%TFKULK Умножение линейной системы на константу
%     n       k*n
% w = -  wr = ---
%     d        d
% где n,d - полиномы, k - константа

function wr = tfmulk(w,k)

  [n,d] = tfdata(w,'v');
  wr = tf(k*n,d);

% End of file
