% CE3 - Вычислительный эксперимент ╧3
% Попытка ╧4

%echo on

% Исходные данные задачи
% Рассчитаем полиномы в числителе и знаменателе операторныx функций

%% y-уставка
Ny = 2;
Dy = [3 1]; %conv([2.4 1], [2.7 1]);
%
%% o-объект
No = 1; %conv([4 1], [7 1]);
Do = 1; %conv([10 1], [16.8 1]);
%
%% n-помеха
Nn = 0.2;
Dn = 1; %[0.3 1];

% Рассчитаем полиномиальные операторные функции звеньев
% W = N / D
Wy = tf(Ny, Dy);
Wo = tf(No, Do);
Wn = tf(Nn, Dn);

[Wp, Wt] = wienreg(Wy, Wn, Wo);
disp('Total transfer function');
tfchain(Wt);
disp('Regulator transfer function');
tfchain(Wp);
