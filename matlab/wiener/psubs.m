%PSUBS  �������� �� ������� �������� ������
% Example:
% P1 = [ 1 2 3 ], P2 = [ 1 3 ]
% psubs(P1,P2) = [ 1 1 0 ]
function q = psubs(p1,p2)

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

q = p1 - p2;

% End of file