
#ifndef unix
#pragma hdrstop
#include <condefs.h>
#endif /* unix */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <NaGenerl.h>
#include <NaExcept.h>
#include <NaDataIO.h>

//---------------------------------------------------------------------------
#ifndef unix
USELIB("..\NeuArch\NeuArch.lib");
USELIB("..\StaDev\stadev32.lib");
#endif /* unix */
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
NaReal  ask_user (const char* szPrompt, NaReal fDefault);

//---------------------------------------------------------------------------
// Ask for integer parameter
int     ask_user (const char* szPrompt, int iDefault);

//---------------------------------------------------------------------------
// Ask for boolean parameter
bool    ask_user (const char* szPrompt, bool bDefault = true);

//---------------------------------------------------------------------------
// Structure for one-dimension description
struct DataSet
{
    char    *fname;         // file name
    NaDataFile  *df;        // file handle
    int     cells;          // number of subranges
    NaReal  min, max;       // min and max of the whole range
    NaReal  width, step;    // computed width (max-min) and step (width/cells)

}   ds[2];


//---------------------------------------------------------------------------
// Preprocess data set (fill min, max, width, cells)
void    dataset_preproc (DataSet& ds);

//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
    if(3 != argc && 4 != argc){
        printf("Usage: Distr2D.exe FName1.dat FName2.dat [FName.map]\n");
        return 1;
    }

    char    *szMapName = "distr2d.map";
    ds[0].fname = argv[1];
    ds[1].fname = argv[2];
    if(argc > 3){
        szMapName = argv[3];
    }

    try{
        ds[0].df = OpenInputDataFile(ds[0].fname);
        dataset_preproc(ds[0]);

        ds[1].df = OpenInputDataFile(ds[1].fname);
        dataset_preproc(ds[1]);

        // allocate map
        int     *map = new int[ds[0].cells * ds[1].cells];
        int     i0, i1, nTotal = 0, nMissed = 0;

        // initialize the map
        for(i0 = 0; i0 < ds[0].cells; ++i0){
            for(i1 = 0; i1 < ds[1].cells; ++i1){
                map[i0 * ds[1].cells + i1] = 0;
            }
        }

        // fill the map
        for(ds[0].df->GoStartRecord(), ds[1].df->GoStartRecord();
            ds[0].df->GoNextRecord() && ds[1].df->GoNextRecord();
            ++nTotal){
            NaReal  x[2];

            x[0] = ds[0].df->GetValue();
            i0 = (x[0] - ds[0].min) / ds[0].step;

            x[1] = ds[1].df->GetValue();
            i1 = (x[1] - ds[1].min) / ds[1].step;

            if(i0 < 0 || i0 >= ds[0].cells ||
               i1 < 0 || i1 >= ds[1].cells){
                ++nMissed;
                continue;
            }

            ++map[i0 * ds[1].cells + i1];
        }

        // print the map
        char    cellchar[] = ".1234567890$$$$$#####%%%%%@@@@@>";
        FILE    *fpMap = fopen(szMapName, "w");
        int     nCovered = 0;   // number of covered cells

        for(i0 = 0; i0 < ds[0].cells; ++i0){
            for(i1 = 0; i1 < ds[1].cells; ++i1){
                int j = map[i0 * ds[1].cells + i1];

                if(j > 0){
                    ++nCovered;
                }

                if(j >= (int)strlen(cellchar)){
                    j = strlen(cellchar) - 1;
                }
                fputc(cellchar[j], fpMap);
            }
            fputc('\n', fpMap);
        }

        fprintf(fpMap, "\nCell characters: %s\n"
                "Total (X,Y)-pairs: %d\n"
                "Percent of coverage: %4.1f %%\n"
                "Percent of missing: %4.1f %%\n"
                "X dimension: %s (min=%g max=%g step=%g cells=%d)\n"
                "Y dimension: %s (min=%g max=%g step=%g cells=%d)\n",
                cellchar, nTotal,
                (NaReal)nCovered * 100 / (ds[0].cells * ds[1].cells),
                (NaReal)nMissed * 100 / nTotal,
                ds[1].fname, ds[1].min, ds[1].max, ds[1].step, ds[1].cells,
                ds[0].fname, ds[0].min, ds[0].max, ds[0].step, ds[0].cells);

        fclose(fpMap);

        delete ds[0].df;
        delete ds[1].df;
    }
    catch(NaException& ex){
        NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
    }
    return 0;
}


//---------------------------------------------------------------------------
// Preprocess data set (fill min, max, width, cells)
void
dataset_preproc (DataSet& ds)
{
    printf("*** Lets describe data from file '%s' ***\n", ds.fname);

    // read data from file and determine min and max
    if(!ds.df->GoStartRecord()){
        printf("Empty file '%s'\n", ds.fname);
    }else{
        ds.max = ds.min = ds.df->GetValue();
        while(ds.df->GoNextRecord()){
            NaReal  v = ds.df->GetValue();
            if(v > ds.max){
                ds.max = v;
            }
            if(v < ds.min){
                ds.min = v;
            }
        }

        printf("There are %d values in the file.\n", ds.df->CountOfRecord());

        // ask user about data range (propose defined)
        ds.min = ask_user("Enter low bound for data", ds.min);
        ds.max = ask_user("Enter high bound for data", ds.max);
        
        ds.width = ds.max - ds.min;
        printf("Data has range of %g width\n", ds.width);

        // ask user about number of one-dimension cells
        while(ds.cells <= 0){
            ds.cells = ask_user("Enter number of subranges", ds.cells);
        }

        ds.step = ds.width / ds.cells;

        printf("Data range subdivided by %d cells of %g width each\n",
               ds.cells, ds.step);
    }
}


//---------------------------------------------------------------------------
// Ask for real parameter
NaReal
ask_user (const char* szPrompt, NaReal fDefault)
{
    char    enter[30];
    printf("%s <%g>: ", szPrompt, fDefault);
    fgets(enter, 29, stdin);
    if('\0' == enter[0])
        return fDefault;
    return strtod(enter, NULL);
}


//---------------------------------------------------------------------------
// Ask for integer parameter
int
ask_user (const char* szPrompt, int iDefault)
{
    char    enter[30];
    printf("%s <%d>: ", szPrompt, iDefault);
    fgets(enter, 29, stdin);
    if('\0' == enter[0])
        return iDefault;
    return strtol(enter, NULL, 10);
}


//---------------------------------------------------------------------------
// Ask for boolean parameter
bool
ask_user (const char* szPrompt, bool bDefault)
{
    char    enter[30], *szSelVals;
    if(bDefault){
        szSelVals = "<y>,n";
    }else{
        szSelVals = "y,<n>";
    }

    do{
        printf("%s (%s): ", szPrompt, szSelVals);
        fgets(enter, 29, stdin);
    }while('y' != enter[0] && 'n' != enter[0] && '\0' != enter[0]);

    switch(enter[0]){
    case 'y':
        return true;
    case 'n':
        return false;
    }
    return bDefault;
}


//---------------------------------------------------------------------------
