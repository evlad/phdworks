%TFNORM  Нормирует передаточную функцию
% Example:
% tf(0.8198, [0.2 1.02]) => tf(4.099, [1 5.099])
function F = tfnorm(W)

[N, D] = tfdata(W, 'v');
[N, D] = pqnorm(N, D);
F = tf(N, D);

% End of file