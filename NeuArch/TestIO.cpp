/* TestIO.cpp */
static char rcsid[] = "$Id: TestIO.cpp,v 1.2 2001-05-15 06:02:24 vlad Exp $";

#pragma hdrstop
#include <condefs.h>

#include <NaDataIO.h>

//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
    NaDataFile  *pInDF = OpenInputDataFile(argv[1]);
    NaDataFile  *pOutDF = OpenOutputDataFile(argv[2]);
    return 0;
}
