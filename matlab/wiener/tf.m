%TF(NUM,DEN,DT)  Линейная система задается полиномами числителя, знаменателя и
% шага дискретизации
function W = tf(NUM, DEN, DT)

if nargin >= 1
  W.num = NUM;
  W.den = DEN;
end
if nargin >= 2
  W.den = DEN;
end
if nargin >= 3
  W.dt = DT;
else
  W.dt = 1;
end

% End of file
