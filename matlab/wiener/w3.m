% CE3 - �������������� ����������� �3
% ������� �3
% ����������� ������������ ������������� ����������� �� ��������
% �������� ��� ��� �������� �������� �������, ������ � ���������
% �������.

%echo on
%clc

% �������� ������ ������
% ���������� �������� � ��������� � ����������� ����������x �������

% y-�������
Ny = 3;
Dy = conv([9 1], [21 1]);

% o-������
No = conv([4 1], [7 1]);
Do = conv([10 1], [16.8 1]);

% n-������
Nn = 0.2;
Dn = conv([3 1], [5 1]);

% ���������� �������������� ����������� ������� �������
% W = N / D
Wy = tf(Ny, Dy)
Wo = tf(No, Do)
Wn = tf(Nn, Dn)

% ���������� ������������ �������������� �������
% (��� ����� ���� �� �����): S = |W|^2 = W * W`
Sy = tfsqmod(Wy)
So = tfsqmod(Wo)
Sn = tfsqmod(Wn)

% ������� ��^2: Fsq = |F|^2 = F * F`
Fsq = Sy + Sn

% ��������� � ����������� ������� �� � ���� ������������� ���������
[Fsqnum,Fsqden] = tfdata(Fsq,'v');

% ����������� �������� ������� ��: KF * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1))

Rnum = roots(Fsqnum)
Rden = roots(Fsqden)

% ������� �� F � ����������� � ��� Fc = F`
Nf = poly(- Rnum(1:2:length(Rnum)) .* Rnum(2:2:length(Rnum)))
Df = poly(- Rden(1:2:length(Rden)) .* Rden(2:2:length(Rden)))
Nf = Kf * Nf;

F = tf(Nf, Df)
%Fc = tfadjoint(F)

% ������� �� � �� �����������:
%        Nf              Nf`
%    F = --,   Fc = F` = --
%        Df              Df`
%
% ���:
%      Nf * Nf` = Ny * Ny` * Dn * Dn` + Nn * Nn` * Dy * Dy`
%      Df * Df` = Dn * Dn` * Dy * Dy` = (Dn * Dy) * (Dn * Dy)`
%        => Df = Dn * Dy

% ��� ��� �����, ����� �� ������ ������� ��� ������ ������ �������,
% ������������� Shy = 1, ��� h(t) - ������ �� ������ �������.
%     1    Df`   Dn` * Dy`
% A = -- = --- = ---------
%     F`   Nf`      Nf`   

Na = conv(padjoint(Dn), padjoint(Dy));
Da = padjoint(Nf);

A = tf(Na, Da);

% �������� �� ������� ����� �������������� ��������� A
[Ar,Ap,Ak] = residue(Na,Da)
Bsum = [];
n = 0;
for i = 1:length(Ar),
   if Ap(i) < 0
      Bsum = [ Bsum tf(Ar(i), poly(Ap(i))) ];
      n = n + 1;
   end
end

%             Ar(i)
% Bsum(i) = --------,   ��� P(i)<0, i=1:N
%           s - Ap(i)
% B = sum(Bsum)
B = Bsum(1);
for i = 2:n,
   B = B + Bsum(i);
end

%Bsum

% �������� B �� ��������� � �����������
[Nb,Db] = tfdata(B, 'v');
Nb = ppack(Nb);

% ��������� ����������� B ��������� �� ����������� A,
% � Da = Dy * Nf` � F` ����� ��� ������ � ������ �������������
% => ��� ����� Da � ����� ������������� - ��� ����� Dy
% ��� ������, ��� Db = Dy

% Wt - ����������� ������� �������
%      B   Nb   Df   Nb   Dy * Dn   Nb * Dn
% Wt = - = -- * -- = -- * ------- = -------
%      F   Db   Nf   Dy     Nf        Nf

% Wp - ������� ����������, ��������������� ������� � �����������
% ������ � ����� ������ �������� ��� ��� �������� ������� y � ������ n
%        Wp * Wo                Wt
% Wt = ----------- => Wp = -------------
%      1 - Wp * Wo         Wo * (1 - Wt)
Wt = B / F;

%              Nb * Dn   Nf - Nb * Dn
% 1 - Wt = 1 - ------- = ------------
%                Nf           Nf
%
%      Do   Nb * Dn         Nf           Do * Nb * Dn
% Wp = -- * -------- * ------------ = -------------------
%      No     Nf       Nf - Nb * Dn   No * (Nf - Nb * Dn)

Np = conv(conv(Nb, Dn), Do);
Dp = conv(No, psubs(Nf, conv(Nb, Dn)));

Wp = tf(Np, Dp)

% ����������� � �����:
%      Np      (1 + Tn s)...
% Wp = -- = Kp -------------
%      Dp      (1 + Td s)...
RNp = roots(Np);
RDp = roots(Dp);

[ Kp ,Tn, Td ] = tfchain(Wp);
