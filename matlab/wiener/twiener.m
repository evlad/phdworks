% Test for WIENER
%   Wy = tf(1, [1 1]); % Уставка
%   Wn = tf(0.2, 1);   % Помеха
%   Wo = tf(1, 1);     % Объект
%   Wt = WIENER(Wy, Wn, Wo);
%   => Wt = tf(0.8198, [0.2 1.02]);

Wy = tf(1, [1 1]); % Уставка
Wn = tf(0.2, 1);   % Помеха
Wo = tf(1, 1);     % Объект
Wt = tfnorm(wiener(Wy, Wn, Wo));
Wt
disp('Must be');
Qt = tf(4.099, [1 5.099])

% End of file