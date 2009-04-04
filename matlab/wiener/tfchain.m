%TFCHAIN  Вычисляет цепочку простейших линейных звеньев по указанной
% функции системы.
function [K, Tn, Td] = tfchain(W)

[N, D] = tfdata(W, 'v');
N = ppack(N);
D = ppack(D);

K = N(1) / D(1);

RN = roots(N);
RD = roots(D);

Tn = [];
for i = 1:length(RN),
   K = K * (- RN(i));
   Tn(i) = - 1 / RN(i);
end

Td = [];
for i = 1:length(RD),
   K = K / (- RD(i));
   Td(i) = - 1 / RD(i);
end

disp(sprintf('K=\t%f', K));
disp(sprintf('Tn=\t'));
for i = 1:length(Tn),
   disp(sprintf('\t%f', Tn(i)));
end
disp(sprintf('Td=\t'));
for i = 1:length(Td),
   disp(sprintf('\t%f', Td(i)));
end

% End of file