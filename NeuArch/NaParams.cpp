//---------------------------------------------------------------------------

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "NaExcept.h"
#include "NaLogFil.h"
#include "NaParams.h"

#define COMMENT		0
#define ASSIGN		1


//---------------------------------------------------------------------------
// Open file with parameters
NaParams::NaParams (const char* szFileName,
		    const char szSpecChar[2])
{
  if(NULL == szSpecChar || NULL == szFileName)
    throw(na_null_pointer);

  spec[COMMENT] = szSpecChar[COMMENT];
  spec[ASSIGN] = szSpecChar[ASSIGN];

  // open file
  FILE	*fp = fopen(szFileName, "r");
  if(NULL == fp)
    throw(na_cant_open_file);

  // read file to get number of lines in it
  stored_n = 0;

  while(NULL != fgets(buf, NaPARAM_LINE_MAX_LEN, fp))
    {
      // skip leading spaces
      char	*p;

      // skip leading spaces before name
      p = buf;
      while(isspace(*p) && *p != '\0')
	++p;
      if(*p != '\0' && *p != spec[COMMENT])
	// non-empty line
	++stored_n;
      // else
      //   no name in this line due to empty line
    }

  // rewind file
  rewind(fp);

  // allocate storage
  if(0 == stored_n)
    {
      NaPrintLog("File '%s' does not contain parameters.\n",
		 szFileName);
      storage = NULL;
    }
  else
    {
      int	item_i = 0;
      storage = new item_t[stored_n];

      // read file to the storage
      while(NULL != fgets(buf, NaPARAM_LINE_MAX_LEN, fp))
	{
	  // parse line of text
	  char	*name, *value, *eov;

	  // skip leading spaces before name
	  name = buf;
	  while(isspace(*name) && *name != '\0')
	    ++name;
	  if(*name == '\0' || *name == spec[COMMENT])
	    // no name in this line due to empty or comment line
	    continue;

	  // find end of the name
	  value = name;
	  while(!isspace(*value) && *value != '\0' &&
		*value != spec[ASSIGN])
	    ++value;

	  if(*value == spec[ASSIGN])
	    {
	      // assignment is found just after the name
	      *value = '\0';	// end of the name
	      ++value;	// start of the value
	    }
	  else
	    {
	      // assignment still is not found
	      *value = '\0';	// end of the name
	      ++value;	// start of the region to find value

	      if(NULL == (value = strchr(value, spec[ASSIGN])))
		// no assignment char in the line
		value = "?absent";
	      else
		++value;
	    }

	  // skip leading spaces before value
	  while(isspace(*value) && *value != '\0')
	    ++value;

	  // skip final spaces after value
	  eov = value + strlen(value);

	  // twice check due to MS-DOS \r\n 
	  if('\n' == eov[-1] || '\r' == eov[-1])
	    --eov;
	  if('\n' == eov[-1] || '\r' == eov[-1])
	    --eov;
	  *eov = '\0';

	  // skip final spaces after value
	  while(isspace(*eov))
	    --eov;

	  *eov = '\0';

	  NaPrintLog("name='%s' value='%s'\n", name, value);

	  storage[item_i].name = new char[strlen(name) + 1];
	  strcpy(storage[item_i].name, name);

	  storage[item_i].value = new char[strlen(value) + 1];
	  strcpy(storage[item_i].value, value);

	  // go to next line and next item
	  ++item_i;
	}

      stored_n = item_i;
    }

  fclose(fp);

  // quick sort the storage
  qsort(storage, stored_n, sizeof(item_t), stored_cmp);
}


//---------------------------------------------------------------------------
NaParams::~NaParams ()
{
  delete storage;
}


//---------------------------------------------------------------------------
// Get parameter's value by his name
char*
NaParams::GetParam (const char* szParamName) const
{
  item_t	it, *pit;
  it.name = (char*)szParamName;
  it.value = NULL;

  char	*szParamValue = "?not found";

  pit = (item_t*)bsearch(&it, storage, stored_n, sizeof(item_t), stored_cmp);
  if(NULL != pit)
    szParamValue = pit->value;

  NaPrintLog("Query for parameter '%s' gives value '%s'\n",
	     szParamName, szParamValue);

  return szParamValue;
}


//---------------------------------------------------------------------------
// Compare two items
int
NaParams::stored_cmp (const void* p1, const void* p2)
{
  const item_t	*it1 = (item_t*)p1, *it2 = (item_t*)p2;
  return strcmp(it1->name, it2->name);
}


//---------------------------------------------------------------------------
#pragma package(smart_init)

#if 0
/***********************************************************************
 * Test of NaParams class.
 ***********************************************************************/
#include <stdio.h>

#include <NaLogFil.h>
#include <NaExcept.h>

#include <NaParams.h>


main (int argc, char* argv[])
{
  if(2 != argc)
    {
      fprintf(stderr, "Usage: testpar ParamFile\n");
      return 1;
    }

  try{
    NaParams	par(argv[1]);
    char	*names[] = {
      "parA", "parB", "parC", "parD", "parE", "parF", "par?"
    };
    int	i;

    for(i = 0; i < sizeof(names); ++i)
      printf("name='%s' -> value='%s'\n", names[i], par(names[i]));
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
#endif
