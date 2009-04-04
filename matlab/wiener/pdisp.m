%PDISP  Выдает полином в читаемой форме
% Example:
% P = [ 0 0 3.4 -17 ]
% pdisp(P)
% 0 s^3 + 0 s^2 + 3.4 s - 17
function str = pdisp(p)

str = '';
np = length(p);
for i = 1:np,
   if sign(p(i)) < 0
      spi = ' -';
   else
      spi = ' +';
   end
   api = abs(p(i));
   ppi = np - i;
   if i == 1 & i == np
      str = [str sprintf('%g', p(i))];
   elseif i == 1 & i ~= np
      str = [str sprintf('%g s^%d', p(i), ppi)];
   elseif i ~= 1 & i == np
      str = [str sprintf('%s %g', spi, api)];
   else % i ~= 1 & i ~= np
      str = [str sprintf('%s %g s^%d', spi, api, ppi)];
   end
end

% End of file