/* NaCoFunc.cpp */
static char rcsid[] = "$Id: NaCoFunc.cpp,v 1.2 2002-03-19 21:56:00 vlad Exp $";

#include <string.h>
#include <stdlib.h>

#include "NaTrFunc.h"
#include "NaCuFunc.h"

#include "NaCoFunc.h"


//-----------------------------------------------------------------------
// Registrar for the NaCombinedFunc
NaConfigPart*
NaCombinedFunc::NaRegCombinedFunc ()
{
  return new NaCombinedFunc();
}


//-----------------------------------------------------------------------
// Make empty combined function
NaCombinedFunc::NaCombinedFunc ()
  : NaConfigPart(NaTYPE_CombinedFunc),
    nParts(0), pParts(NULL),
    conf_file(";NeuCon combined function", 1, 0, ".cof")
{
  // Nothing to do
}


//-----------------------------------------------------------------------
// Destructor
NaCombinedFunc::~NaCombinedFunc ()
{
  Clean();
}


//-----------------------------------------------------------------------
// Print self
void
NaCombinedFunc::PrintLog () const
{
  PrintLog(NULL);
}


//-----------------------------------------------------------------------
// Print self with indentation
void
NaCombinedFunc::PrintLog (const char* szIndent) const
{
  unsigned	i;
  const char	*indent = (NULL == szIndent)? "": szIndent;

  NaPrintLog("%sCombined function %s:\n", indent,
	     (NULL == GetInstance())? "": GetInstance());
  for(i = 0; i < nParts; ++i){
    NaPrintLog("%s  %s %s\n", indent,
	       pParts[i]->GetType(), pParts[i]->GetInstance());
  }
}


//-----------------------------------------------------------------------
// Is empty
bool
NaCombinedFunc::Empty () const
{
  return 0 == nParts;
}


//-----------------------------------------------------------------------
// Make empty
void
NaCombinedFunc::Clean ()
{
  nParts = 0;
  delete[] pParts;
}


//***********************************************************************
// Unit part
//***********************************************************************

//-----------------------------------------------------------------------
// Reset operations, that must be done before new modelling
// will start
void
NaCombinedFunc::Reset ()
{
  unsigned	i;
  for(i = 0; i < nParts; ++i){
    NaUnit	*pUnit = (NaUnit*)pParts[i]->pSelfData;
    pUnit->Reset();
  }
}


//-----------------------------------------------------------------------
// Compute output on the basis of internal parameters,
// stored state and external input: y=F(x,t,p)
void
NaCombinedFunc::Function (NaReal* x, NaReal* y)
{
  unsigned	i;
  NaReal	tmp;

  for(i = 0; i < nParts; ++i){
    NaUnit	*pUnit = (NaUnit*)pParts[i]->pSelfData;
    if(0 == i)
      pUnit->Function(x, &tmp);
    else{
      pUnit->Function(&tmp, y);
      tmp = *y;
    }
  }
  *y = tmp;
}


//***********************************************************************
// Store and retrieve configuration data
//***********************************************************************

//-----------------------------------------------------------------------
// Store configuration data in internal order to given stream
void
NaCombinedFunc::Save (NaDataStream& ds)
{
  unsigned	i;
  for(i = 0; i < nParts; ++i){
    ds.PutF(NULL, "%s %s", pParts[i]->GetType(), pParts[i]->GetInstance());
  }
}


struct item_t {
  char	*szType;
  char	*szInstance;
};


//-----------------------------------------------------------------------
// Retrieve configuration data in internal order from given stream
void
NaCombinedFunc::Load (NaDataStream& ds)
{
  // Remove all previous functions
  Clean();

  item_t	item;
  NaDynAr<item_t>	items;

  // Read line-by-line
  while(true){
    try{
      char	*szType, *szInstance, *s = ds.GetData();

      szType = strtok(s, " ");
      szInstance = strtok(NULL, " ");

      if(NULL == szType || NULL == szInstance)
	continue;

      if(strcmp(szType, NaTYPE_CustomFunc) &&
	 strcmp(szType, NaTYPE_TransFunc)){
	NaPrintLog("Function type '%s' is not defined -> skip it.\n", szType);
	continue;
      }

      item.szType = new char[strlen(szType) + 1];
      item.szInstance = new char[strlen(szInstance) + 1];

      strcpy(item.szType, szType);
      strcpy(item.szInstance, szInstance);

      items.addh(item);

    }catch(NaException exCode){
      if(na_end_of_partition == exCode ||
	 na_end_of_file == exCode)
	break;
      NaPrintLog("Exception %s while NaCombinedFunc::Load(ds)\n",
		 NaExceptionMsg(exCode));
    }
  }
  // EOF or end of partition is reached

  // Lets make array of partitions
  nParts = items.count();
  pParts = new NaConfigPart*[nParts];

  unsigned	i;
  for(i = 0; i < nParts; ++i){
    if(!strcmp(items[i].szType, NaTYPE_TransFunc)){
      NaTransFunc	*p = new NaTransFunc;
      pParts[i] = p;
      pParts[i]->pSelfData = (NaUnit*)p;
    }else if(!strcmp(items[i].szType, NaTYPE_CustomFunc)){
      NaCustomFunc	*p = new NaCustomFunc;
      pParts[i] = p;
      pParts[i]->pSelfData = (NaUnit*)p;
    }
    pParts[i]->SetInstance(items[i].szInstance);

    delete[] items[i].szType;
    delete[] items[i].szInstance;
  }

  // Register all expected partitions
  conf_file.AddPartitions(nParts, pParts);
}


//-----------------------------------------------------------------------
// Store sequence of functions to file
void
NaCombinedFunc::Save (const char* szFileName)
{
  conf_file.SaveToFile(szFileName);
}


//-----------------------------------------------------------------------
// Read sequence of functions from given configuration file.  Smart
// enough to take care of transfer (.tf) and combined functions (.cof)
void
NaCombinedFunc::Load (const char* szFileName)
{
  if(NULL == szFileName)
    throw(na_null_pointer);
  if(strlen(szFileName) >= 3){
    if(!strcmp(szFileName + strlen(szFileName) - 3, ".tf")){
      // Old transfer function file
      Clean();

      nParts = 1;
      pParts = new NaConfigPart*[nParts];

      NaTransFunc	*p = new NaTransFunc;
      pParts[0] = p;
      pParts[0]->pSelfData = (NaUnit*)p;

      conf_file.RemovePartitions();
      conf_file.AddPartitions(nParts, pParts);
      conf_file.LoadFromFile(szFileName);

      // To be fully compatible with Save() of .cof format
      NaConfigPart	*conf_list[] = { this, p };
      conf_file.RemovePartitions();
      conf_file.AddPartitions(NaNUMBER(conf_list), conf_list);

      return;
    }
  }

  // Combined function file
  NaConfigPart	*conf_list[] = { this };
  conf_file.RemovePartitions();
  conf_file.AddPartitions(NaNUMBER(conf_list), conf_list);
  conf_file.LoadFromFile(szFileName);
}
