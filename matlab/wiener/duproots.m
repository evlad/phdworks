%DUPROOTS  ������� ������������� ����� �� ��������� � �����������
% �������������� �����.
% Rp(s)   prod (s - p(i))    Ra(s)   prod (s - a(i))
% ----- = --------------- => ----- = ---------------, a(i) ~= b(j)
% Rq(s)   prod (s - q(j))    Rb(s)   prod (s - b(j))
% ����� ��������� ������� �.�. ���� 28 ������ 2001 ����. ������ 1.1
function [Ra,Rb] = duproots(Rp,Rq)

% ������-������� ������������� ������
Cp = ones(1,length(Rp));
Cq = ones(1,length(Rq));

% ���� �� ������ ���������
for i = 1:length(Rp)
   % ���� �� ������ �����������
   for j = 1:length(Rq)
      if Cq(j) == 1 & abs(Rp(i) - Rq(j)) < 0.001
         % �������� ������ ����� ������ Rp(i) � Rq(j)
         Cp(i) = 0;
         Cq(j) = 0;
      end
   end
end

Ra = Rp(find(Cp));
Rb = Rq(find(Cq));

% End of file
