% CE3 - Вычислительный эксперимент ╧3
% Попытка ╧3
% Определение оптимального регулирующего воздействия по критерию
% минимума СКО при заданных спектрах уставки, помехи и известном
% объекте.

%echo on
%clc

% Исходные данные задачи
% Рассчитаем полиномы в числителе и знаменателе операторныx функций

% y-уставка
Ny = 3;
Dy = conv([9 1], [21 1]);

% o-объект
No = conv([4 1], [7 1]);
Do = conv([10 1], [16.8 1]);

% n-помеха
Nn = 0.2;
Dn = conv([3 1], [5 1]);

% Рассчитаем полиномиальные операторные функции звеньев
% W = N / D
Wy = tf(Ny, Dy)
Wo = tf(No, Do)
Wn = tf(Nn, Dn)

% Рассчитаем спектральные характеристики звеньев
% (при белом шуме на входе): S = |W|^2 = W * W`
Sy = tfsqmod(Wy)
So = tfsqmod(Wo)
Sn = tfsqmod(Wn)

% Функция Фи^2: Fsq = |F|^2 = F * F`
Fsq = Sy + Sn

% Числитель и знаменатель функции Фи в виде коэффициентов полиномов
[Fsqnum,Fsqden] = tfdata(Fsq,'v');

% Коэффициент усиления функции Фи: KF * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1))

Rnum = roots(Fsqnum)
Rden = roots(Fsqden)

% Функция Фи F и сопряженная к ней Fc = F`
Nf = poly(- Rnum(1:2:length(Rnum)) .* Rnum(2:2:length(Rnum)))
Df = poly(- Rden(1:2:length(Rden)) .* Rden(2:2:length(Rden)))
Nf = Kf * Nf;

F = tf(Nf, Df)
%Fc = tfadjoint(F)

% Функция Фи и ее сопряженная:
%        Nf              Nf`
%    F = --,   Fc = F` = --
%        Df              Df`
%
% где:
%      Nf * Nf` = Ny * Ny` * Dn * Dn` + Nn * Nn` * Dy * Dy`
%      Df * Df` = Dn * Dn` * Dy * Dy` = (Dn * Dy) * (Dn * Dy)`
%        => Df = Dn * Dy

% Так как хотим, чтобы на выходе системы был сигнал равный уставке,
% следовательно Shy = 1, где h(t) - сигнал на выходе системы.
%     1    Df`   Dn` * Dy`
% A = -- = --- = ---------
%     F`   Nf`      Nf`   

Na = conv(padjoint(Dn), padjoint(Dy));
Da = padjoint(Nf);

A = tf(Na, Da);

% Разложим на простые дроби полиномиальное отношение A
[Ar,Ap,Ak] = residue(Na,Da)
Bsum = [];
n = 0;
for i = 1:length(Ar),
   if Ap(i) < 0
      Bsum = [ Bsum tf(Ar(i), poly(Ap(i))) ];
      n = n + 1;
   end
end

%             Ar(i)
% Bsum(i) = --------,   где P(i)<0, i=1:N
%           s - Ap(i)
% B = sum(Bsum)
B = Bsum(1);
for i = 2:n,
   B = B + Bsum(i);
end

%Bsum

% Разложим B на числитель и знаменатель
[Nb,Db] = tfdata(B, 'v');
Nb = ppack(Nb);

% Поскольку знаменатель B получился из знаменателя A,
% а Da = Dy * Nf` и F` имеет все полюса в правой полуплоскости
% => все корни Da в левой полуплоскости - это корни Dy
% Это значит, что Db = Dy

% Wt - оптимальная функция системы
%      B   Nb   Df   Nb   Dy * Dn   Nb * Dn
% Wt = - = -- * -- = -- * ------- = -------
%      F   Db   Nf   Dy     Nf        Nf

% Wp - функция регулятора, поддерживающего систему в оптимальном
% режиме с точки зрения минимума СКО при заданном сигнале y и помехе n
%        Wp * Wo                Wt
% Wt = ----------- => Wp = -------------
%      1 - Wp * Wo         Wo * (1 - Wt)
Wt = B / F;

%              Nb * Dn   Nf - Nb * Dn
% 1 - Wt = 1 - ------- = ------------
%                Nf           Nf
%
%      Do   Nb * Dn         Nf           Do * Nb * Dn
% Wp = -- * -------- * ------------ = -------------------
%      No     Nf       Nf - Nb * Dn   No * (Nf - Nb * Dn)

Np = conv(conv(Nb, Dn), Do);
Dp = conv(No, psubs(Nf, conv(Nb, Dn)));

Wp = tf(Np, Dp)

% Представить в форме:
%      Np      (1 + Tn s)...
% Wp = -- = Kp -------------
%      Dp      (1 + Td s)...
RNp = roots(Np);
RDp = roots(Dp);

[ Kp ,Tn, Td ] = tfchain(Wp);
