//-*-C++-*-
/* NaGenerl.h */
/* $Id: NaGenerl.h,v 1.2 2001-04-23 06:17:23 vlad Exp $ */
#ifndef __NaGeneral_h
#define __NaGeneral_h

#include <stdio.h>


/*************************************************************
 * Universal atomic type for data item representation.
 *************************************************************/
typedef double	NaReal;


/*************************************************************
 * Universal precision for floating point operations.
 *************************************************************/
#define NaPRECISION     1e-10


/*************************************************************
 * Compute number of items in explicitly defined array
 *************************************************************/
#define NaNUMBER(x)     (sizeof(x)/sizeof(x[0]))


/*************************************************************
 * Get sign of a number
 *************************************************************/
#define NaSIGN(x)       ((x) < 0? -1: 1)

/*************************************************************
 * Maximum number of hidden layers in neural network.
 *************************************************************/
#define NaMAX_HIDDEN    3


/*************************************************************
 * Common logging stream.
 *************************************************************/
extern FILE *fpNaLog;


#endif /* NaGeneral.h */
