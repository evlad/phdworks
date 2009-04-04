k = 2
T = 3
c = 0.2

sqc = sqrt(k^2 + c^2);

Tt = (T * c) / (sqc)

Kt = k^2 / ((c + sqc) * sqc)

Wp = tf( Kt/(1 - Kt), [ Tt 1 ])
