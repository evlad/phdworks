% CE3 - �������������� ����������� �3
% ������� �5 (A)

%echo on

% �������� ������ ������
% ���������� �������� � ��������� � ����������� ����������x �������

% y-�������
Ny = 2;
Dy = [3 1];

% o-������
No = [35 5];
Do = [15 1];

% n-������
Nn = 0.2;
Dn = [0.1 1];

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
