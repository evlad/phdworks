//-*-C++-*-
/* NaStrOps.h */
/* $Id: NaStrOps.h,v 1.2 2001-05-15 06:02:23 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaStrOpsH
#define NaStrOpsH

//---------------------------------------------------------------------------
// General string operations


// Allocate new string and copy its from given in argument
char*       newstr (const char* s);

// Autoname facility
char*       autoname (const char* root, int& iCounter);

//---------------------------------------------------------------------------
#endif
