%WIENER  Синтез оптимальной физически осуществимой передаточной
% функции системы по критерию минимума СКО при заданных передаточных
% функциях уставки, помехи и объекта.  Метод Винера (1949 год).
% Автор программы Елисеев В.Л. Дата 14 января 2001 года. Версия 1.2
% Example:
%   Wy = tf(1, [1 1]); % Уставка
%   Wn = tf(0.2, 1);   % Помеха
%   Wt = WIENER(Wy, Wn);
%   => Wt = tf(4.099, [1 5.099]);
%   или Wt = tf(0.8198, [0.2 1.02]);
function Wt = wiener(Wy, Wn)

% Исходные данные задачи
% Рассчитаем полиномы в числителе и знаменателе операторныx функций
% где W = N / D

% y-уставка
[Ny, Dy] = tfdata(Wy, 'v');
[Ny, Dy] = pqnorm(Ny, Dy);

% n-помеха
[Nn, Dn] = tfdata(Wn, 'v');
[Nn, Dn] = pqnorm(Nn, Dn);

% Рассчитаем спектральные характеристики звеньев
% (при белом шуме на входе): S = |W|^2 = W * W`
Sy = tfsqmod(tf(Ny, Dy));
Sn = tfsqmod(tf(Nn, Dn));

% Функция Фи^2: Fsq = |F|^2 = F * F` = Sy + Sn
Fsq = Sy + Sn;

% Числитель и знаменатель функции |F|^2 в виде коэффициентов полиномов
[Fsqnum, Fsqden] = tfdata(Fsq, 'v');

% Коэффициент усиления функции Фи: KF * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% Все корни числителя и знаменателя F * F`
Rnum = roots(Fsqnum);
Rden = roots(Fsqden);

% Получаем корни F
Rnum = Rnum(1:2:length(Rnum)) .* Rnum(2:2:length(Rnum));
Rden = Rden(1:2:length(Rden)) .* Rden(2:2:length(Rden));

Rnum = - sqrt(Rnum);
Rden = - sqrt(Rden);

% Функция Фи F
Nf = Kf * poly(Rnum);
Df = poly(Rden);
%disp('____Nf____');
%Nf

%disp('____F____');
F = tf(Nf, Df);
%tfchain(F);
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

%     Sy   Ny * Ny`  Df`   Ny * Ny`   Dn` * Dy`   Ny * Ny` * Dn`
% A = -- = ------- * --- = -------- * --------- = --------------
%     F`   Dy * Dy`  Nf`   Dy * Dy`      Nf`         Dy * Nf`

Na = conv(conv(Ny, padjoint(Ny)), padjoint(Dn));
%disp('____Nf`____');
%padjoint(Nf)
%disp('____Dy____');
%Dy
Da = conv(Dy, padjoint(Nf));
[Na, Da] = pqnorm(Na, Da);
%disp('____Sy/F`____');
A = tf(Na, Da);
%tfchain(A);

% Разложим на простые дроби полиномиальное отношение A
%Na
%Da
[Ar, Ap, Ak] = residue(Na, Da);

Bsum = [];
Asum = [];
n = 0;
for i = 1:length(Ar),
   Asum = [ Asum tf(Ar(i), poly(Ap(i))) ];
   if Ap(i) < 0
      Bsum = [ Bsum tf(Ar(i), poly(Ap(i))) ];
      n = n + 1;
   end
end
%disp('____Asum____');
%Asum
%tfchain(Asum(1));
%tfchain(Asum(2));

%             Ar(i)
% Bsum(i) = --------,   где P(i)<0, i=1:N
%           s - Ap(i)
% B = sum(Bsum)
B = Bsum(1);
for i = 2:n,
   B = B + Bsum(i);
end

%disp('____B____');
%B
%tfchain(B);

% Разложим B на числитель и знаменатель
[Nb, Db] = tfdata(B, 'v');
[Nb, Db] = pqnorm(Nb, Db);
%Nb = ppack(Nb);
%Db = ppack(Db);
%Kb = Nb(1) / Db(1);
%Nb = Nb / Nb(1);
%Db = Db / Db(1);

% Поскольку знаменатель B получился из знаменателя A,
% а Da = Dy * Nf` и F` имеет все полюсы в правой полуплоскости
% => все корни Da в левой полуплоскости - это корни Dy
% Это значит, что Db = Dy

% Wt - оптимальная функция системы
%      B   Kb * Nb     Df      Kb * Nb   Dy * Dn   Kb * Nb * Dn
% Wt = - = ------- * ------- = ------- * ------- = ------------
%      F     Db      Kf * Nf     Dy      Kf * Nf     Kf * Nf
% При этом надо привести F и B к одному и тому же виду П(s - s(i))

%disp('____Wt____');
%Nf = ppack(Nf);
%Df = ppack(Df);
%Kf = Nf(1) / Df(1);
%Nf = Nf / Nf(1);
%Df = Df / Df(1);

[Nf, Df] = pqnorm(Nf, Df);

%Nt = (Kb / Kf) * conv(Nb, Dn);

[Nt, Dt] = pqnorm(conv(Nb, Dn), Nf);
%Dt = Nf;

Wt = tf(Nt, Dt);  % Wt = B / F
%tfchain(Wt);
%Wt = B / F

% End of file