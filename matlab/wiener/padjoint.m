%PADJOINT  Вычисляет сопряженный полином
% Example:
% P(s) = 1 + s + s^2 => P(-s) = 1 - s + s^2
function adj = padjoint(pol)

n = length(pol);

adj = pol;
for i = 1:n,
   adj(i) = sign((- 1)^(n - i)) * pol(i);
end

% End of file