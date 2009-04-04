%PADD  Складывает первый полином и второй
% Example:
% P1 = [ 1 2 3 ], P2 = [ 1 3 ]
% padd(P1,P2) = [ 1 3 6 ]
function q = padd(p1,p2)

np1 = length(p1);
np2 = length(p2);

if np1 < np2
   for i = 1:(np2 - np1)
      p1 = [ 0 p1 ];
   end
elseif np1 > np2
   for i = 1:(np1 - np2)
      p2 = [ 0 p2 ];
   end
end

q = ppack(p1 + p2);

% End of file