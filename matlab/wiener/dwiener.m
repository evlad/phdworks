%DWIENER  Синтез дискретной оптимальной физически осуществимой передаточной
% функции системы по критерию минимума СКО при заданных передаточных
% функциях уставки, помехи и объекта.  Метод Винера (1949 год).
% Автор программы Елисеев В.Л. Дата 5 апреля 2009 года. Версия 1.1
function Wt = dwiener(Sy, Sn)

% t - Шаг дискретизации - из Sy
[Ny, Dy, t, dummy] = tfdata(Sy, 'v');

% Функция Фи^2: Fsq = |F|^2 = F * F` = Sy + Sn
Fsq = tfadd(Sy, Sn);

% Числитель и знаменатель функции |F|^2 в виде коэффициентов полиномов
[Fsqnum, Fsqden] = tfdata(Fsq, 'v');

% Коэффициент усиления функции Фи: Kf * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% Удалить корни, повторяющиеся в числителе и в знаменателе
[Rnum, Rden] = duproots(roots(Fsqnum), roots(Fsqden));

%Rnum

% Должно быть четное число корней
if 0 ~= rem(length(Rnum), 2)
   error('odd number of numerator roots in Fsq');
end
if 0 ~= rem(length(Rden), 2)
   error('odd number of denumerator roots in Fsq');
end

%return

% Так как по определению спектральной плотности корни в числителе и в
% знаменателе группируются как комплексно-сопряженные и обратные,
% то можно поделить их пополам (зная, что после roots они отсортированы
% по убыванию):

% Индексы первой половины корней Rnum и Rden
iRn1 = 1+length(Rnum)/2:length(Rnum);
iRd1 = 1+length(Rden)/2:length(Rden);

% Индексы второй половины корней Rnum и Rden
iRn2 = 1:length(Rnum)/2;
iRd2 = 1:length(Rden)/2;

%Rnum
%Rnum(iRn1)
%Rnum(iRn2)

% Функция Фи F(z) - все нули и полюсы |z|<=1
Nf = Kf * poly(Rnum(iRn1));
Df = poly(Rden(iRd1));
%disp('____Nf____');
%Nf

%disp('____F____');
F = tf(Nf, Df, t);
%Rden(iRd1)
%tfchain(F);
%Fc = tfadjoint(F)

% Функция Фи` Fс(z)=F(1/z) - сопряженная  - все нули и полюсы |z|>=1
Nfc = Kf * poly(Rnum(iRn2));
Dfc = poly(Rden(iRd2));
%disp('____Nfc____');
%Nf

%disp('____Fc____');
Fc = tf(Nfc, Dfc, t);
%Rden(iRd2)

% F * Fc должно быть равно Fsq

% Sy(z)    Ny * Dfc               r(i)
% ------ = -------- = k + sum ( -------- )
% F(1/z)   Dy * Nfc             z - p(i)
Na = conv(Ny, Dfc);
Da = conv(Dy, Nfc);
%tf(Na,Da,-1)
[r,p,k] = residue(Na, Da);

%r
%p
%abs(p)
%k
%return

if length(r) ~= length(p) | length(k) ~= 0
   error('residue problems');
   return
end

% Выбрать нули |p(i)| <= 1, такие, что r(i)!=0
r0 = [];
p0 = [];
for i = 1:length(p)
   if abs(p(i)) < 1.001 & abs(r(i)) > 0.001
      %disp('ok');
      p0 = [ p0 p(i) ];
      r0 = [ r0 r(i) ];
   end
end

%r0
%p0
%return

% Возвратить обратно в полиномиальную форму, но уже без ненужных корней
[Nb, Db] = residue(r0, p0, 0.0);

% Wt - оптимальная функция системы
%      B   Nb     Df        Nb * Df
% Wt = - = -- * ------- = ------------
%      F   Db   Kf * Nf   Kf * Nf * Db

[Nt, Dt] = pqnorm(conv(Nb, Df), Kf * conv(Nf, Db));
Kt = sqrt(Nt(1)/Dt(1));
%roots(Nt)
%roots(Dt)
[RNt, RDt] = duproots(roots(Nt), roots(Dt));
Nt = Kt * poly(RNt);
Dt = poly(RDt);
Wt = tf(Nt, Dt, t);  % Wt = B / F
%tfchain(Wt);

% End of file
