%TFDATA(W)
% 
function [NUM,DEN,DT,DUMMY2] = tfdata(W, DUMMY1)

  NUM = W.num;
  DEN = W.den;

  if (nargout > 2)
    DT = W.dt;
  endif

% End of file
