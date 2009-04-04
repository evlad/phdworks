% Test for WIENER
%   Wy = tf(1, [1 1]); % �������
%   Wn = tf(0.2, 1);   % ������
%   Wo = tf(1, 1);     % ������
%   Wt = WIENER(Wy, Wn, Wo);
%   => Wt = tf(0.8198, [0.2 1.02]);

Wy = tf(1, [1 1]); % �������
Wn = tf(0.2, 1);   % ������
Wo = tf(1, 1);     % ������
Wt = tfnorm(wiener(Wy, Wn, Wo));
Wt
disp('Must be');
Qt = tf(4.099, [1 5.099])

% End of file