//-*-C++-*-
//---------------------------------------------------------------------------
#ifndef NaParamsH
#define NaParamsH


//---------------------------------------------------------------------------
// Class for list of parameters stored in file
// Format of file:
//  <file> ::= <line> <file> | <empty>
//  <line> ::= <comment-line> | <assign-line>
//  <assign-line> ::= <name> "=" <value>
//  <comment-line> ::= "#" <any-characters>

#define NaPARAM_LINE_MAX_LEN	1023

//---------------------------------------------------------------------------
class NaParams
{
public:

  // Open file with parameters
  NaParams (const char* szFileName,
	    /* Special char: comment; assignment */
	    const char szSpecChar[2] = "#=");

  virtual ~NaParams ();

  // Get parameter's value by his name
  char*		GetParam (const char* szParamName) const;
  char*		operator() (const char* szParamName) const{
    return GetParam(szParamName);
  }

protected:

  char	spec[2];
  char	buf[NaPARAM_LINE_MAX_LEN+1];	// Line buffer

  struct item_t {
    char	*name;
    char	*value;
  }	*storage;

  int	stored_n;

  // Compare two items
  static int	stored_cmp (const void* p1, const void* p2);

};


//---------------------------------------------------------------------------
#endif
