/* NaLogFil.cpp */
static char rcsid[] = "$Id: NaLogFil.cpp,v 1.2 2001-05-15 06:02:21 vlad Exp $";
//---------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef ThreadSafe_BCB
#include <syncobjs.hpp>
#endif // ThreadSafe_BCB

#include "NaLogFil.h"

//---------------------------------------------------------------------------
FILE    *fpNaLog = stdout;

#ifdef ThreadSafe_BCB
// To protect multi-threaded bugs
TCriticalSection    *TheLogFileLock;
#endif // ThreadSafe_BCB

//---------------------------------------------------------------------------
// Open log file
void    NaOpenLogFile (const char* szFile)
{
    if(NULL == szFile)
        return;

    if(fpNaLog != stdout && fpNaLog != stderr){
        fclose(fpNaLog);
    }

#ifdef ThreadSafe_BCB
    if(NULL == TheLogFileLock)
        TheLogFileLock = new TCriticalSection();
#endif // ThreadSafe_BCB

#ifdef ThreadSafe_BCB
    TheLogFileLock->Enter();
#endif // ThreadSafe_BCB

    fpNaLog = fopen(szFile, "w");

#ifdef ThreadSafe_BCB
    TheLogFileLock->Leave();
#endif // ThreadSafe_BCB

    NaPrintLog("Logging started.\n");
}

//---------------------------------------------------------------------------
// Close log file
void    NaCloseLogFile ()
{
    if(NULL == fpNaLog)
        return;

    NaPrintLog("Logging finished.\n");

#ifdef ThreadSafe_BCB
    TheLogFileLock->Enter();
#endif // ThreadSafe_BCB

    fclose(fpNaLog);
    fpNaLog = NULL;

#ifdef ThreadSafe_BCB
    TheLogFileLock->Leave();
#endif // ThreadSafe_BCB
}


//---------------------------------------------------------------------------
// Turn on/off logging
void    NaSwitchLogFile (bool state)
{
    static FILE *fpStored = NULL;

#ifdef ThreadSafe_BCB
    TheLogFileLock->Enter();
#endif // ThreadSafe_BCB

    if(false == state && NULL == fpStored && NULL != fpNaLog){
        fpStored = fpNaLog;
        fpNaLog = NULL;
    }
    else if(true == state && NULL != fpStored && NULL == fpNaLog){
        fpNaLog = fpStored;
        fpStored = NULL;
    }

#ifdef ThreadSafe_BCB
    TheLogFileLock->Leave();
#endif // ThreadSafe_BCB
}

//---------------------------------------------------------------------------
// Prints a message to log file if it's open
void    NaPrintLog (const char* fmt, ...)
{
#ifdef ThreadSafe_BCB
    TheLogFileLock->Enter();
#endif // ThreadSafe_BCB

    va_list argptr;

    if(NULL == fpNaLog)
        return;

    va_start(argptr, fmt);
    vfprintf(fpNaLog, fmt, argptr);
    fflush(fpNaLog);
    va_end(argptr);

#ifdef ThreadSafe_BCB
    TheLogFileLock->Leave();
#endif // ThreadSafe_BCB
}

//---------------------------------------------------------------------------
// Print log without indentation
void
NaLogging::PrintLog () const
{
    // Dummy
}

//---------------------------------------------------------------------------
// Print log with indentation
//void
//NaLogging::PrintLog (const char* szIndent) const
//{
//    NaPrintLog("%s", szIndent);
//    PrintLog();
//}

//---------------------------------------------------------------------------

