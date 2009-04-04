%DWIENER  ������ ���������� ����������� ��������� ������������ ������������
% ������� ������� �� �������� �������� ��� ��� �������� ������������
% �������� �������, ������ � �������.  ����� ������ (1949 ���).
% ����� ��������� ������� �.�. ���� 2 ������� 2001 ����. ������ 1.0
function Wt = dwiener(Sy, Sn)

% t - ��� ������������� - �� Sy
[Ny, Dy, t, dummy] = tfdata(Sy, 'v');

% ������� ��^2: Fsq = |F|^2 = F * F` = Sy + Sn
Fsq = Sy + Sn;

% ��������� � ����������� ������� |F|^2 � ���� ������������� ���������
[Fsqnum, Fsqden] = tfdata(Fsq, 'v');

% ����������� �������� ������� ��: Kf * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% ������� �����, ������������� � ��������� � � �����������
[Rnum, Rden] = duproots(roots(Fsqnum), roots(Fsqden));

% ������ ���� ������ ����� ������
if 0 ~= rem(length(Rnum), 2)
   error('odd number of numerator roots in Fsq');
end
if 0 ~= rem(length(Rden), 2)
   error('odd number of denumerator roots in Fsq');
end

%return

% ��� ��� �� ����������� ������������ ��������� ����� � ��������� � �
% ����������� ������������ ��� ����������-����������� � ��������,
% �� ����� �������� �� ������� (����, ��� ����� roots ��� �������������
% �� ��������):

% ������� ������ �������� ������ Rnum � Rden
iRn1 = 1+length(Rnum)/2:length(Rnum);
iRd1 = 1+length(Rden)/2:length(Rden);

% ������� ������ �������� ������ Rnum � Rden
iRn2 = 1:length(Rnum)/2;
iRd2 = 1:length(Rden)/2;

%Rnum
%Rnum(iRn1)
%Rnum(iRn2)

% ������� �� F(z) - ��� ���� � ������ |z|<=1
Nf = Kf * poly(Rnum(iRn1));
Df = poly(Rden(iRd1));
%disp('____Nf____');
%Nf

%disp('____F____');
F = tf(Nf, Df, t);
%Rden(iRd1)
%tfchain(F);
%Fc = tfadjoint(F)

% ������� ��` F�(z)=F(1/z) - �����������  - ��� ���� � ������ |z|>=1
Nfc = Kf * poly(Rnum(iRn2));
Dfc = poly(Rden(iRd2));
%disp('____Nfc____');
%Nf

%disp('____Fc____');
Fc = tf(Nfc, Dfc, t);
%Rden(iRd2)

% F * Fc ������ ���� ����� Fsq

% Sy(z)    Ny * Dfc               r(i)
% ------ = -------- = k + sum ( -------- )
% F(1/z)   Dy * Nfc             z - p(i)
Na = conv(Ny, Dfc);
Da = conv(Dy, Nfc);
%tf(Na,Da,-1)
[r,p,k] = residue(Na, Da);

%r
%p
%abs(p)
%k
%return

if length(r) ~= length(p) | length(k) ~= 0
   error('residue problems');
   return
end

% ������� ���� |p(i)| <= 1, �����, ��� r(i)!=0
r0 = [];
p0 = [];
for i = 1:length(p)
   if abs(p(i)) < 1.001 & abs(r(i)) > 0.001
      %disp('ok');
      p0 = [ p0 p(i) ];
      r0 = [ r0 r(i) ];
   end
end

%r0
%p0
%return

% ���������� ������� � �������������� �����, �� ��� ��� �������� ������
[Nb, Db] = residue(r0, p0, 0.0);

% Wt - ����������� ������� �������
%      B   Nb     Df        Nb * Df
% Wt = - = -- * ------- = ------------
%      F   Db   Kf * Nf   Kf * Nf * Db

[Nt, Dt] = pqnorm(conv(Nb, Df), Kf * conv(Nf, Db));
Kt = sqrt(Nt(1)/Dt(1));
%roots(Nt)
%roots(Dt)
[RNt, RDt] = duproots(roots(Nt), roots(Dt));
Nt = Kt * poly(RNt);
Dt = poly(RDt);
Wt = tf(Nt, Dt, t);  % Wt = B / F
%tfchain(Wt);

% End of file
