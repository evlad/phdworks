% CE3 - �������������� ����������� �3
% ������� �4

%echo on

% �������� ������ ������
% ���������� �������� � ��������� � ����������� ����������x �������

% y-�������
Ny = 3;
%Dy = conv([9 1], [21 1]);
Dy = [9 1];

% o-������
No = conv([4 1], [7 1]);
Do = conv([10 1], [16.8 1]);
%Do = [10 1];

% n-������
Nn = 0.2;
Dn = conv([1.2 1], [0.5 1]);

% ���������� �������������� ����������� ������� �������
% W = N / D
Wy = tf(Ny, Dy);
Wo = tf(No, Do);
Wn = tf(Nn, Dn);

[Wp, Wt] = wienreg(Wy, Wn, Wo);
disp('Total transfer function');
tfchain(Wt);
disp('Regulator transfer function');
tfchain(Wp);
