%DS1  ���������� ���������� ������������ ��������� ��� ������������
% ������������ ������� ����:
%            K
% W(s) = ---------
%        s(1 + Ts)
% �����:
%              K^2
% S(w) = -----------------
%        w^2*(1 + T^2*w^2)
%
% ������� S(z) = Z{S(-jp)} (������������, �.565)
%
%                     b^2                    1       1
% S(z) = K^2 * Z{-------------} = K^2 * Z{------- - ---} =>
%                p^2*(p^2-b^2)            p^2-b^2   p^2
%
%         2 1      z sinh bt            zt
% S(z) = K (- -------------------- - ---------)
%           b z^2 - 2z cosh bt + 1   (z - 1)^2
% ��� b=1/T, t - ��� ������������� �������
% ����� ��������� ������� �.�. ���� 5 ������ 2009 ����. ������ 1.1
function Sz = ds1(K, T, t)

b = 1/T;

tf1 = tf([sinh(b*t)/b 0], [1 -2*cosh(b*t) 1], t);
tf2 = tf([t 0], conv([1 -1], [1 -1]), t);

Sz = tfmulk((tfsub(tf1, tf2)), K^2);

% End of file
