%DUPROOTS  Удаляет повторяющиеся корни из числителя и знаменателя
% полиномиальной дроби.
% Rp(s)   prod (s - p(i))    Ra(s)   prod (s - a(i))
% ----- = --------------- => ----- = ---------------, a(i) ~= b(j)
% Rq(s)   prod (s - q(j))    Rb(s)   prod (s - b(j))
% Автор программы Елисеев В.Л. Дата 28 января 2001 года. Версия 1.1
function [Ra,Rb] = duproots(Rp,Rq)

% Массив-счетчик повторяющихся корней
Cp = ones(1,length(Rp));
Cq = ones(1,length(Rq));

% Цикл по корням числителя
for i = 1:length(Rp)
   % Цикл по корням знаменателя
   for j = 1:length(Rq)
      if Cq(j) == 1 & abs(Rp(i) - Rq(j)) < 0.001
         % Сбросить флажек учета корней Rp(i) и Rq(j)
         Cp(i) = 0;
         Cq(j) = 0;
      end
   end
end

Ra = Rp(find(Cp));
Rb = Rq(find(Cq));

% End of file
