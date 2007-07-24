
#ifndef _simpsonq_h
#define _simpsonq_h

#include "ap.h"

/*-----------------------------------------------
This routines must be defined by you:

double f(double x);
-----------------------------------------------*/

/*************************************************************************
�������������� ������� �������� � ������� ��������.

��������� �������� ������� F �� ������� [a,b] � ������������
������� Epsilon.
*************************************************************************/
double integralsimpson(const double& a,
     const double& b,
     const double& epsilon);


#endif
