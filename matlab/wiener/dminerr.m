%DMINERR  ������ ������������������ ������ ���������� �����������
% �������� �������.  ����� ������ (1949 ���).
% ����� ��������� ������� �.�. ���� 28 ������ 2001 ����. ������ 1.1
function Emin = dminerr(Sy, Sn)

% ������� ��^2: Fsq = |F|^2 = F * F` = Sy + Sn
%Fsq = Sy + Sn;
Fsq = tf(conv(Sy.num,Sn.den).+conv(Sy.den,Sn.num),
	 conv(Sy.den, Sn.den), Sy.dt);

% ��������� � ����������� ������� |F|^2 � ���� ������������� ���������
% t - ��� ������������� - �� |F|^2
[Fsqnum, Fsqden, t, dummy] = tfdata(Fsq, 'v');

% ����������� �������� ������� ��: Kf * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% ������� �����, ������������� � ��������� � � �����������
%roots(Fsqnum)
%roots(Fsqden)
[Rnum, Rden] = duproots(roots(Fsqnum), roots(Fsqden));

% ������ ���� ������ ����� ������
if 0 ~= rem(length(Rnum), 2)
   error('odd number of numerator roots in Fsq');
end
if 0 ~= rem(length(Rden), 2)
   error('odd number of denumerator roots in Fsq');
end

% ��� ��� �� ����������� ������������ ��������� ����� � ��������� � �
% ����������� ������������ ��� ����������-����������� � ��������,
% �� ����� �������� �� ������� (����, ��� ����� roots ��� �������������
% �� ��������):

% ������� ������ �������� ������ Rnum � Rden
iRn1 = 1+length(Rnum)/2:length(Rnum);
iRd1 = 1+length(Rden)/2:length(Rden);

% ������� �� F(z) - ��� ���� � ������ |z|<=1
Nf = Kf * poly(Rnum(iRn1));
Df = poly(Rden(iRd1));
F = tf(Nf, Df, t);

% ��������� ���� ����� F(z) -> f(t), �� ���� ����� �������� �� �������
% |z|=1 �� F(z)/z.
% Emin = f^2(0), ��� f(i*T) - ���� ���������� � ��� ������ �� �������� z
% � ����������� ����� 0.
%                       r(i)
% F(z) = k(z) + sum ( -------- )
%                i    z - p(i)
[Rf,Pf,Kf] = residue(Nf, conv(Df, [1 0]));

%Pf = ppack(Pf);
%Rf = ppack(Pf);

%1/Pf(1)

if length(Rf) ~= length(Pf) | 0 ~= length(Kf)
   error('residue problems');
   return
end

% �������� ����� ����� ������� ��������������� ������� ������ |z|=1:
%iInside=[];
%return
phi0 = 0;
for i = 1:length(Pf)
   if abs(Pf(i)) < 1
      %disp(Pf(i));
      %iInside = [iInside i]; 
      phi0 = phi0 + abs(Rf(i));
    end
end
%iInside
%phi0
%return

Emin = phi0 * phi0;

% End of file