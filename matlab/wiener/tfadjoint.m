%TFADJOINT  Вычисляет сопряженную функцию системы
% Example:
%             1                      1
% H(s) = ----------- => H(-s)  = -----------
%        1 + s + s^2             1 - s + s^2
function adj = tfadjoint(sys)

[num,den] = tfdata(sys,'v');

%nn = length(num);
%nd = length(den);
%for i = 1:nn,
%   num(i) = sign((- 1)^(nn - i)) * num(i);
%end
%for i = 1:nd,
%   den(i) = sign((- 1)^(nd - i)) * den(i);
%end

adj = tf(padjoint(num), padjoint(den));

% End of file