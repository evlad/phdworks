%DMINERR  Расчет среднеквадратичной ошибки дискретной оптимальной
% следящей системы.  Метод Винера (1949 год).
% Автор программы Елисеев В.Л. Дата 28 января 2001 года. Версия 1.1
function Emin = dminerr(Sy, Sn)

% Функция Фи^2: Fsq = |F|^2 = F * F` = Sy + Sn
%Fsq = Sy + Sn;
Fsq = tf(conv(Sy.num,Sn.den).+conv(Sy.den,Sn.num),
	 conv(Sy.den, Sn.den), Sy.dt);

% Числитель и знаменатель функции |F|^2 в виде коэффициентов полиномов
% t - Шаг дискретизации - из |F|^2
[Fsqnum, Fsqden, t, dummy] = tfdata(Fsq, 'v');

% Коэффициент усиления функции Фи: Kf * F
Pnum = ppack(Fsqnum);
Pden = ppack(Fsqden);
Kf = sqrt(Pnum(1)/Pden(1));

% Удалить корни, повторяющиеся в числителе и в знаменателе
%roots(Fsqnum)
%roots(Fsqden)
[Rnum, Rden] = duproots(roots(Fsqnum), roots(Fsqden));

% Должно быть четное число корней
if 0 ~= rem(length(Rnum), 2)
   error('odd number of numerator roots in Fsq');
end
if 0 ~= rem(length(Rden), 2)
   error('odd number of denumerator roots in Fsq');
end

% Так как по определению спектральной плотности корни в числителе и в
% знаменателе группируются как комплексно-сопряженные и обратные,
% то можно поделить их пополам (зная, что после roots они отсортированы
% по убыванию):

% Индексы первой половины корней Rnum и Rden
iRn1 = 1+length(Rnum)/2:length(Rnum);
iRd1 = 1+length(Rden)/2:length(Rden);

% Функция Фи F(z) - все нули и полюсы |z|<=1
Nf = Kf * poly(Rnum(iRn1));
Df = poly(Rden(iRd1));
F = tf(Nf, Df, t);

% Поскольку ищем образ F(z) -> f(t), то надо взять интеграл по контуру
% |z|=1 от F(z)/z.
% Emin = f^2(0), где f(i*T) - член разложения в ряд Лорана по степеням z
% в окрестности точки 0.
%                       r(i)
% F(z) = k(z) + sum ( -------- )
%                i    z - p(i)
[Rf,Pf,Kf] = residue(Nf, conv(Df, [1 0]));

%Pf = ppack(Pf);
%Rf = ppack(Pf);

%1/Pf(1)

if length(Rf) ~= length(Pf) | 0 ~= length(Kf)
   error('residue problems');
   return
end

% Интеграл равен сумме вычетов подинтегральной функции внутри |z|=1:
%iInside=[];
%return
phi0 = 0;
for i = 1:length(Pf)
   if abs(Pf(i)) < 1
      %disp(Pf(i));
      %iInside = [iInside i]; 
      phi0 = phi0 + abs(Rf(i));
    end
end
%iInside
%phi0
%return

Emin = phi0 * phi0;

% End of file