%TFKULK ��������� �������� ������� �� ���������
%     n       k*n
% w = -  wr = ---
%     d        d
% ��� n,d - ��������, k - ���������

function wr = tfmulk(w,k)

  [n,d] = tfdata(w,'v');
  wr = tf(k*n,d);

% End of file
