%PPACK  Удаляет ведущие нулевые коэффициенты полинома
% Example:
% P(s) = 0 s^4 + 0 s^3 + 3.4 s^2 + 17 => P(s) = 3.4 s^2 + 17
function q = ppack(p)

% Non-zero indeces
nzi = find(p);

% From first non-zero to end
if 0 == length(nzi)
   q = [];
else
   q = p(nzi(1):length(p));
end

% End of file