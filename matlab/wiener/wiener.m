%WIENER  ������ ����������� ��������� ������������ ������������
% ������� ������� �� �������� �������� ��� ��� �������� ������������
% �������� �������, ������ � �������.  ����� ������ (1949 ���).
% ����� ��������� ������� �.�. ���� 14 ������ 2001 ����. ������ 1.2
% Example:
%   Wy = tf(1, [1 1]); % �������
%   Wn = tf(0.2, 1);   % ������
%   Wt = WIENER(Wy, Wn);
%   => Wt = tf(4.099, [1 5.099]);
%   ��� Wt = tf(0.8198, [0.2 1.02]);
function Wt = wiener(Wy, Wn)

% �������� ������ ������
% ���������� �������� � ��������� � ����������� ����������x �������
% ��� W = N / D

% y-�������
[Ny, Dy] = tfdata(Wy, 'v');
[Ny, Dy] = pqnorm(Ny, Dy);

% n-������
[Nn, Dn] = tfdata(Wn, 'v');
[Nn, Dn] = pqnorm(Nn, Dn);

% ���������� ������������ �������������� �������
% (��� ����� ���� �� �����): S = |W|^2 = W * W`
Sy = tfsqmod(tf(Ny, Dy));
Sn = tfsqmod(tf(Nn, Dn));

% ������� ��^2: Fsq = |F|^2 = F * F` = Sy + Sn
Fsq = Sy + Sn;

% ��������� � ����������� ������� |F|^2 � ���� ������������� ���������
[Fsqnum, Fsqden] = tfdata(Fsq, 'v');

% ����������� �������� ������� ��: KF * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% ��� ����� ��������� � ����������� F * F`
Rnum = roots(Fsqnum);
Rden = roots(Fsqden);

% �������� ����� F
Rnum = Rnum(1:2:length(Rnum)) .* Rnum(2:2:length(Rnum));
Rden = Rden(1:2:length(Rden)) .* Rden(2:2:length(Rden));

Rnum = - sqrt(Rnum);
Rden = - sqrt(Rden);

% ������� �� F
Nf = Kf * poly(Rnum);
Df = poly(Rden);
%disp('____Nf____');
%Nf

%disp('____F____');
F = tf(Nf, Df);
%tfchain(F);
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

%     Sy   Ny * Ny`  Df`   Ny * Ny`   Dn` * Dy`   Ny * Ny` * Dn`
% A = -- = ------- * --- = -------- * --------- = --------------
%     F`   Dy * Dy`  Nf`   Dy * Dy`      Nf`         Dy * Nf`

Na = conv(conv(Ny, padjoint(Ny)), padjoint(Dn));
%disp('____Nf`____');
%padjoint(Nf)
%disp('____Dy____');
%Dy
Da = conv(Dy, padjoint(Nf));
[Na, Da] = pqnorm(Na, Da);
%disp('____Sy/F`____');
A = tf(Na, Da);
%tfchain(A);

% �������� �� ������� ����� �������������� ��������� A
%Na
%Da
[Ar, Ap, Ak] = residue(Na, Da);

Bsum = [];
Asum = [];
n = 0;
for i = 1:length(Ar),
   Asum = [ Asum tf(Ar(i), poly(Ap(i))) ];
   if Ap(i) < 0
      Bsum = [ Bsum tf(Ar(i), poly(Ap(i))) ];
      n = n + 1;
   end
end
%disp('____Asum____');
%Asum
%tfchain(Asum(1));
%tfchain(Asum(2));

%             Ar(i)
% Bsum(i) = --------,   ��� P(i)<0, i=1:N
%           s - Ap(i)
% B = sum(Bsum)
B = Bsum(1);
for i = 2:n,
   B = B + Bsum(i);
end

%disp('____B____');
%B
%tfchain(B);

% �������� B �� ��������� � �����������
[Nb, Db] = tfdata(B, 'v');
[Nb, Db] = pqnorm(Nb, Db);
%Nb = ppack(Nb);
%Db = ppack(Db);
%Kb = Nb(1) / Db(1);
%Nb = Nb / Nb(1);
%Db = Db / Db(1);

% ��������� ����������� B ��������� �� ����������� A,
% � Da = Dy * Nf` � F` ����� ��� ������ � ������ �������������
% => ��� ����� Da � ����� ������������� - ��� ����� Dy
% ��� ������, ��� Db = Dy

% Wt - ����������� ������� �������
%      B   Kb * Nb     Df      Kb * Nb   Dy * Dn   Kb * Nb * Dn
% Wt = - = ------- * ------- = ------- * ------- = ------------
%      F     Db      Kf * Nf     Dy      Kf * Nf     Kf * Nf
% ��� ���� ���� �������� F � B � ������ � ���� �� ���� �(s - s(i))

%disp('____Wt____');
%Nf = ppack(Nf);
%Df = ppack(Df);
%Kf = Nf(1) / Df(1);
%Nf = Nf / Nf(1);
%Df = Df / Df(1);

[Nf, Df] = pqnorm(Nf, Df);

%Nt = (Kb / Kf) * conv(Nb, Dn);

[Nt, Dt] = pqnorm(conv(Nb, Dn), Nf);
%Dt = Nf;

Wt = tf(Nt, Dt);  % Wt = B / F
%tfchain(Wt);
%Wt = B / F

% End of file