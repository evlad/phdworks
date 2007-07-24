
#ifndef _simpsonq_h
#define _simpsonq_h

#include "ap.h"

/*-----------------------------------------------
This routines must be defined by you:

double f(double x);
-----------------------------------------------*/

/*************************************************************************
Интегрирование методом Симпсона с оценкой точности.

Считается интеграл функции F на отрезке [a,b] с погрешностью
порядка Epsilon.
*************************************************************************/
double integralsimpson(const double& a,
     const double& b,
     const double& epsilon);


#endif
