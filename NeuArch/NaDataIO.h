//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaDataIOH
#define NaDataIOH
//---------------------------------------------------------------------------

#include "NaGenerl.h"
#include "NaExcept.h"

//---------------------------------------------------------------------------
// Supported file formats
enum NaFileFormat{
    ffTextStream = 0,   // Simple value-space-value format
    ffStatistica,       // STATISTICA packet file format
    ffDPlot,            // DPLOT/W v.1.2 file format
    ffUnknown           // Unknown file format - can't guess anything
};

//---------------------------------------------------------------------------
// Number of alternatives
#define __ffNumber      ffUnknown

//---------------------------------------------------------------------------
// Supported file formats' specifics

#define NaIO_STATISTICA_MAGIC   "CSS "
#define NaIO_DPLOT_MAGIC        "DPLOT/W v1.2"

// Filename extension
#define NaIO_TEXT_STREAM_EXT    ".DAT"
#define NaIO_STATISTICA_EXT     ".STA"
#define NaIO_DPLOT_EXT          ".GRF"


//---------------------------------------------------------------------------
// Modes of file opening
enum NaFileMode {
    fmReadOnly = 0,
    fmCreateEmpty
};

//---------------------------------------------------------------------------
// Class for data file manipulation as a set of variables
class NaDataFile
{
public:

    // Create a stream or simply read it
    NaDataFile (const char* fname,
                NaFileMode fm = fmReadOnly);

    // Close (and write) file
    virtual ~NaDataFile ();

    //***********************************
    // File format determiner
    //***********************************

    // Guess file format by filename (see .EXT)
    static NaFileFormat GuessFileFormatByName (const char* szFName);

    // Guess file format by quick file observe (read magic)
    static NaFileFormat GuessFileFormatByMagic (const char* szFName);

    //***********************************
    // Per cell operations
    //***********************************

    // Access to data cell in current record
    // Variables are numbered with 0 base
    virtual void    SetValue (NaReal fVal, int iVar = 0) = 0;
    virtual NaReal  GetValue (int iVar = 0) const = 0;

    //***********************************
    // Per record operations
    //***********************************

    // Go to next record
    // Return true if the next record exists
    virtual bool    GoNextRecord () = 0;

    // Go to start record: reset cycle of file reading
    // Return true if the next record exists
    virtual bool    GoStartRecord () = 0;

    // Append one empty record at the end of the file
    virtual void    AppendRecord () = 0;

    // Return number of records in the file
    virtual long    CountOfRecord ();

    //***********************************
    // Variable operations
    //***********************************

    // Get list of variables
    virtual void    GetVarNameList (int& nVars, char**& sVars) = 0;

    // Set name of the variable
    // Variables are numbered with 0 base
    virtual void    SetVarName (int iVar, const char* szVarName) = 0;

    //***********************************
    // Common description of the data
    //***********************************

    // Set title string; many titles are supported
    virtual void    SetTitle (const char* szTitle, int iTitleNo = 0);

    // Get title string; many titles are supported
    virtual const char* GetTitle (int iTitleNo = 0);

protected:

    // File opening mode
    NaFileMode      eFileMode;

    // File name
    char            *szFileName;

    // Current number of records
    long            nRecords;
};

#include "NaTextIO.h"
#ifndef unix
#include "NaStaIO.h"
#endif /* unix */
#include "NaPlotIO.h"


// Create object (NaDataFile descendant) for reading given data file
NaDataFile* OpenInputDataFile (const char* szPath);

// Create object (NaDataFile descendant) for writing given data file
NaDataFile* OpenOutputDataFile (const char* szPath);


//---------------------------------------------------------------------------
#endif
