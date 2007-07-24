
#ifndef _trapeziumq_h
#define _trapeziumq_h

#include "ap.h"

/*-----------------------------------------------
This routines must be defined by you:

double f(double x);
-----------------------------------------------*/

/*************************************************************************
�������������� ������� �������� � ������� ��������.

��������� �������� ������� F �� ������� [a,b] � ������������
������� Epsilon.

function IntegralTrap(a:Real;b:Real;Epsilon:real):real;
*************************************************************************/
double integraltrapezium(const double& a,
     const double& b,
     const double& epsilon);


#endif
