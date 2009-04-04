%DTFSQMOD  Вычисляет квадрат модуля системы при |z|=1, т.е. z`=1/z
% Example:
%           1                                    1
% H(z) = ------- => |H(z)|^2 = H(z)*H(1/z) = -----------
%        1 + T*z                             1 + T^2*z^2
function mod = dtfsqmod(sys)

[num,den] = tfdata(sys,'v');
Rnum = roots(num);
Rden = roots(den);

num = ppack(num);
den = ppack(den);
K = sqrt(num(1)/den(1));

nn = length(Rnum);
nd = length(Rden);

num1 = 1;
for i = 1:nn,
   num1 = conv(num1, conv([1 Rnum(i)], [1 1/Rnum(i)]));
end

den1 = 1;
for i = 1:nd,
   den1 = conv(den1, conv([1 Rden(i)], [1 1/Rden(i)]));
end

mod = tf(K*num1, den1, -1);

% End of file