%UFILTER Controller force filter computation on the basis of R -
% reference signal filter, G - controlled plant, N - noise signal
% filter.
% Example:
%   Gn = [];  Gd = [];
%   Rn = [];  Rd = [];
%   Nn = [];  Nd = [];
% [] = 
   Wn = tf(0.2, 1);   % ������
%   Wt = WIENER(Wy, Wn);
%   => Wt = tf(4.099, [1 5.099]);
%   ��� Wt = tf(0.8198, [0.2 1.02]);
function Wt = wiener(Wy, Wn)

#####################################
# ���������� ������� ������������
# ����������� ��� �������� �������,
# ������ � �������
#####################################
#           R(z)
# U(z) = -----------
#        G(z) + N(z)

