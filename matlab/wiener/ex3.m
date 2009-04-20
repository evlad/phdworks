%EX3  ������ 3: ������ ���������� ����������� ������������ �������
% ����� ��������� ������� �.�. ���� 28 ������ 2001 ����. ������ 1.0
function ex3()

% ������� - ������������������ ������ ������������ ������������ �������
%            K
% W(s) = ---------
%        s(1 + Ts)
Sy = ds1(2, 3, 0.15)

% ������ - ������������������ ������ ������������ ������������ �������
%            K
% W(s) = ---------
%        s(1 + Ts)
Sn = ds1(0.2, 0.1, 0.15)

% ���������� ����������� ������������ �������
Wt = dwiener(Sy, Sn)
%[Nt, Dt] = tfdata(Wt, 'v');
%[Nt, Dt] = pqnorm(Nt, Dt);
%Kt = Nt(1)/Dt(1)
%disp('Num roots:');
%RNt = roots(Nt)
%disp('Den roots:');
%RDt = roots(Dt)

% ����������� ������������������ ������ ���������������
Emin = dminerr(Sy, Sn)

% End of file