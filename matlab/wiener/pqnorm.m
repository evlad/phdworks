%PQNORM  Нормирует полиномы в числителе и знаменателе
% Example:
% [0 2 5 0 7]/[4 0 9] => [0.5 1.25 0 1.75]/[1 0 2.25]
function [N, D] = pqnorm(P, Q)

N = ppack(P);
D = ppack(Q);
K = N(1) / D(1);
N = K * N / N(1);
D = D / D(1);

% End of file