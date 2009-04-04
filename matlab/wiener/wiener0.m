echo on
% **************************************************************
% ����������� ������������ ������������� ����������� �� ��������
% �������� ��� ��� �������� �������� �������, ������ � ���������
% �������.  ����� ������.  ���������� �������� �.�. 18 ���.1999�
% **************************************************************

echo off
%clc

% �������� ������ ������
% ���������� �������� � ��������� � ����������� ����������x �������

% y-�������
Ny = 1;
Dy = [1 1];

% o-������
No = 1;
Do = 1;

% n-������
Nn = 0.2;
Dn = [2 1];

% ���������� �������������� ����������� ������� �������
% W = N / D
disp('################# ������� ##################');
Wy = tf(Ny, Dy)
disp('################# ������ ###################');
Wo = tf(No, Do)
disp('################# ������ ###################');
Wn = tf(Nn, Dn)

% ���������� ������������ �������������� �������
% (��� ����� ���� �� �����): S = |W|^2 = W * W`
Sy = tfsqmod(Wy);
So = tfsqmod(Wo);
Sn = tfsqmod(Wn);

% ������� ��^2: Fsq = |F|^2 = F * F`
Fsq = Sy + Sn;

% ��������� � ����������� ������� �� � ���� ������������� ���������
[Fsqnum,Fsqden] = tfdata(Fsq,'v');

% ����������� �������� ������� ��: KF * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

Rnum = sqrt(roots(Fsqnum));
Rden = sqrt(roots(Fsqden));

% ������� �� F � ����������� � ��� Fc = F`
Nf = poly(- Rnum(1:2:length(Rnum)) .* Rnum(2:2:length(Rnum)));
Df = poly(- Rden(1:2:length(Rden)) .* Rden(2:2:length(Rden)));
Nf = Kf * Nf;

disp('################# ������� �� ###################');
F = tf(Nf, Df)
%Fc = tfadjoint(F)

[ KF, TFn, TFd ] = tfchain(F);

% ������� �� � �� �����������:
%        Nf              Nf`
%    F = --,   Fc = F` = --
%        Df              Df`
%
% ���:
%      Nf * Nf` = Ny * Ny` * Dn * Dn` + Nn * Nn` * Dy * Dy`
%      Df * Df` = Dn * Dn` * Dy * Dy` = (Dn * Dy) * (Dn * Dy)`
%        => Df = Dn * Dy

%     Sy   Ny * Ny`  Df`   Ny * Ny`   Dn` * Dy`   Ny * Ny` * Dn`
% A = -- = ------- * --- = -------- * --------- = --------------
%     F`   Dy * Dy`  Nf`   Dy * Dy`      Nf`         Dy * Nf`

Na = conv(conv(Ny, padjoint(Ny)), padjoint(Dn));
Da = conv(Dy, padjoint(Nf));

A = tf(Na, Da);

% �������� �� ������� ����� �������������� ��������� A
[Ar,Ap,Ak] = residue(Na,Da);
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
disp('################# ������� Wt ###################');
Wt = B / F

[ KT, TTn, TTd ] = tfchain(Wt);

%              Nb * Dn   Nf - Nb * Dn
% 1 - Wt = 1 - ------- = ------------
%                Nf           Nf
%
%      Do   Nb * Dn         Nf           Do * Nb * Dn
% Wp = -- * -------- * ------------ = -------------------
%      No     Nf       Nf - Nb * Dn   No * (Nf - Nb * Dn)

Np = conv(conv(Nb, Dn), Do);
Dp = conv(No, psubs(Nf, conv(Nb, Dn)));

disp('################# ������� Wp ###################');
Wp = tf(Np, Dp)

% ����������� � �����:
%      Np      (1 + Tn s)...
% Wp = -- = Kp -------------
%      Dp      (1 + Td s)...
RNp = roots(Np);
RDp = roots(Dp);

[ Kp, Tn, Td ] = tfchain(Wp);
