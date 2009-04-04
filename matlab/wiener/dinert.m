%DINERT  Расчет спектральной плотности дискретного аналога
% инерционного звена W(s)=K/(1+Ts) => S(w)=K^2/(1+T^2w^2)
% Автор программы Елисеев В.Л. Дата 24 февраля 2001 года. Версия 1.1
% Example:
%   S = dinert(2,3,0.5)
%   => Transfer function:
%          0.2233 z
%      -----------------
%      z^2 - 2.028 z + 1
%
%      Sampling time: 0.5
function S = dinert(K, T, dT)

  alpha = (K^2)/T;
  beta = 1/T;
  S = tf([alpha * sinh(beta * dT) 0], [1 -2 * cosh(beta * dT) 1], dT);

% End of file
