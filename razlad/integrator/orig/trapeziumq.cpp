
#include <stdafx.h>
#include "trapeziumq.h"

/*************************************************************************
Интегрирование методом трапеций с оценкой точности.

Считается интеграл функции F на отрезке [a,b] с погрешностью
порядка Epsilon.

function IntegralTrap(a:Real;b:Real;Epsilon:real):real;
*************************************************************************/
double integraltrapezium(const double& a,
     const double& b,
     const double& epsilon)
{
    double result;
    int i;
    int n;
    double h;
    double s1;
    double s2;

    n = 1;
    h = b-a;
    s2 = h*(f(a)+f(b))/2;
    do
    {
        s1 = s2;
        s2 = 0;
        i = 1;
        do
        {
            s2 = s2+f(a-h/2+h*i);
            i = i+1;
        }
        while(i<=n);
        s2 = s1/2+s2*h/2;
        n = 2*n;
        h = h/2;
    }
    while(fabs(s2-s1)>3*epsilon);
    result = s2;
    return result;
}



