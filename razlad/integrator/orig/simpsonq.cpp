
#include <stdafx.h>
#include "simpsonq.h"

/*************************************************************************
Интегрирование методом Симпсона с оценкой точности.

Считается интеграл функции F на отрезке [a,b] с погрешностью
порядка Epsilon.
*************************************************************************/
double integralsimpson(const double& a,
     const double& b,
     const double& epsilon)
{
    double result;
    int i;
    int n;
    double h;
    double s;
    double s1;
    double s2;
    double s3;
    double x;

    s2 = 1;
    h = b-a;
    s = f(a)+f(b);
    do
    {
        s3 = s2;
        h = h/2;
        s1 = 0;
        x = a+h;
        do
        {
            s1 = s1+2*f(x);
            x = x+2*h;
        }
        while(x<b);
        s = s+s1;
        s2 = (s+s1)*h/3;
        x = fabs(s3-s2)/15;
    }
    while(x>epsilon);
    result = s2;
    return result;
}



