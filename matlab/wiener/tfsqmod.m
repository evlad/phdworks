%TFSQMOD  Вычисляет квадрат модуля системы
% Example:
%           1                                   1
% H(s) = ------- => |H(s)|^2 = H(s)*H(-s) = -----------
%        1 + T*s                            1 + T^2*s^2
function mod = tfsqmod(sys)

[num,den] = tfdata(sys,'v');
nn = length(num);
nd = length(den);

num1 = num(1)^2;
for i = 2:nn,
   num1 = [ num1 0 num(i)^2 ];
end

den1 = den(1)^2;
for i = 2:nd,
   den1 = [ den1 0 den(i)^2 ];
end

mod = tf(num1, den1);

% End of file