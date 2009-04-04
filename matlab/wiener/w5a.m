% CE3 - Вычислительный эксперимент ╧3
% Попытка ╧5 (A)

%echo on

% Исходные данные задачи
% Рассчитаем полиномы в числителе и знаменателе операторныx функций

% y-уставка
Ny = 2;
Dy = [3 1];

% o-объект
No = [35 5];
Do = [15 1];

% n-помеха
Nn = 0.2;
Dn = [0.1 1];

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
