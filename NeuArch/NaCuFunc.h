//-*-C++-*-
/* NaCuFunc.h */
/* $Id: NaCuFunc.h,v 1.1 2002-02-16 21:34:41 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaCuFuncH
#define NaCuFuncH

#include <NaGenerl.h>
#include <NaUnit.h>
#include <NaConfig.h>
#include <NaDynAr.h>
#include <NaVector.h>
#include <NaLogFil.h>
#include <NaExFunc.h>


// Name of the type for config file
#define NaTYPE_CustomFunc	"CustomFunction"

#define NaCF_file		"file"
#define NaCF_options		"options"
#define NaCF_initial		"initial"

#define NaSHAREDOBJ_DIR_ENV	"NASODIR"

//---------------------------------------------------------------------------
// Class for custum function
class NaCustomFunc : public NaUnit, public NaConfigPart
{
public:

  // Registrar for the NaCustomFunc
  static NaConfigPart*	NaRegCustomFunc ();

  // Make custom function given some shared object file
  NaCustomFunc ();

  // Destructor
  virtual ~NaCustomFunc ();

  // Print self
  virtual void	PrintLog () const;

  // Print self with indentation
  virtual void	PrintLog (const char* szIndent) const;

  // Is empty
  virtual bool	Empty () const;

  // Make empty
  virtual void	Clean ();


  //***********************************************************************
  // Unit part
  //***********************************************************************

  // Reset operations, that must be done before new modelling
  // will start
  virtual void	Reset ();

  // Compute output on the basis of internal parameters,
  // stored state and external input: y=F(x,t,p)
  virtual void	Function (NaReal* x, NaReal* y);

  //***********************************************************************
  // Store and retrieve configuration data
  //***********************************************************************

  // Store configuration data in internal order to given stream
  virtual void	Save (NaDataStream& ds);

  // Retrieve configuration data in internal order from given stream
  virtual void	Load (NaDataStream& ds);

protected:

  // Shared object file name
  char		*szFile;

  // Options
  char		*szOptions;

  // Initial vector
  NaVector	vInitial;

  // Shared object handle
  void		*so;

  // Pointer to external function definition
  NaExternFunc	*exfunc;

};


//---------------------------------------------------------------------------
#endif
