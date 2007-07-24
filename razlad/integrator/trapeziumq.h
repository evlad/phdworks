
#ifndef _trapeziumq_h
#define _trapeziumq_h

#include "ap.h"

/*-----------------------------------------------
This routines must be defined by you:

double f(double x);
-----------------------------------------------*/

/*************************************************************************
Интегрирование методом трапеций с оценкой точности.

Считается интеграл функции F на отрезке [a,b] с погрешностью
порядка Epsilon.

function IntegralTrap(a:Real;b:Real;Epsilon:real):real;
*************************************************************************/
double integraltrapezium(const double& a,
     const double& b,
     const double& epsilon);


#endif
