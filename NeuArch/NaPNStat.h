//-*-C++-*-
/* NaPNStat.h */
/* $Id: NaPNStat.h,v 1.6 2001-12-13 12:27:49 vlad Exp $ */
//---------------------------------------------------------------------------
#ifndef NaPNStatH
#define NaPNStatH

#include <NaPetri.h>


// Condition sign
#define LESS_THAN	(-1)
#define EQUAL_TO	0
#define GREATER_THAN	1

// Statistics id
#define NaSI_ABSMEAN	0
#define NaSI_MEAN	1
#define NaSI_RMS	2
#define NaSI_STDDEV	3
#define NaSI_MAX	4
#define NaSI_MIN	5
#define NaSI_ABSMAX	6

#define NaSI_number	7
#define NaSI_bad_id	(-1)

#define NaSIdToMask(id)	(1<<(id))

// Statistics mask
#define NaSM_ABSMEAN	(1<<0)
#define NaSM_MEAN	(1<<1)
#define NaSM_RMS	(1<<2)
#define NaSM_STDDEV	(1<<3)
#define NaSM_MAX	(1<<4)
#define NaSM_MIN	(1<<5)
#define NaSM_ABSMAX	(1<<6)

#define NaSM_ALL	(NaSM_ABSMEAN | NaSM_MEAN | NaSM_RMS | NaSM_STDDEV | \
			 NaSM_MAX | NaSM_MIN | NaSM_ABSMAX)


// Stat identifier string<->id conversion
const char*	NaStatIdToText (int stat_id);
int		NaStatTextToId (const char* szStatText);


//---------------------------------------------------------------------------
// Applied Petri net node: compute statistics for the N-dimensional signal.
// Has the only input which can be N-dimensional.  Computes mean, StdDeversion
// and mean square error (MSE).

//---------------------------------------------------------------------------
class NaPNStatistics : public NaPetriNode
{
public:

  // Create node for Petri network
  NaPNStatistics (const char* szNodeName = "statistics");


  ////////////////
  // Connectors //
  ////////////////

  // Input (mainstream)
  NaPetriCnInput      signal;

  // Output vector:
  //  [0] absolute mean value: |S(x)/n|
  //  [1] mean value: S(x)/n
  //  [2] root mean square value: S(^2)/n
  //  [3] standard deviation value: S(^2)/n - (S(x)/n)^2
  //  [4] maximum value: Max(x)
  //  [5] minimum value: Min(x)
  //  [6] absolute maximum value: Max(|Max(x)|,|Min(x)|)
  NaPetriCnOutput     stat;


  ///////////////////
  // Node specific //
  ///////////////////

  // Confugure computation rule as continuos or floating gap
  void		set_floating_gap (unsigned gap_width);

  // Confugure output values
  void		configure_output (int stat_mask = NaSM_ALL);

  // Setup net stop condition:
  // sign<0 --> stop if statistics value is less than value
  // sign=0 --> stop if statistics value is equal than value
  // sign>0 --> stop if statistics value is greater than value
  void		halt_condition (int stat_id, int sign, NaReal value);

  // Print to the log statistics
  void		print_stat (const char* szTitle = NULL);


  /////////////////////////
  // Computed statistics //
  /////////////////////////

  // Mean value: M(signal)
  NaVector	Mean;

  // Root mean square: M(signal^2)
  NaVector	RMS;

  // Standard deviation value: d(signal) = sqrt(M(signal^2) - M(signal)^2)
  NaVector	StdDev;

  // Minimum value of the series
  NaVector	Min;

  // Maximum value of the series
  NaVector	Max;



  ///////////////////////
  // Phases of network //
  ///////////////////////

  // 2. Link connectors inside the node
  virtual void	relate_connectors ();

  // 4. Allocate resources for internal usage
  virtual void	allocate_resources ();

  // 5. Verification to be sure all is OK (true)
  virtual bool	verify ();

  // 6. Initialize node activity and setup starter flag if needed
  virtual void	initialize (bool& starter);

  // 8. True action of the node (if activate returned true)
  virtual void	action ();

  // 9. Finish data processing by the node (if activate returned true)
  virtual void	post_action ();

private:

  // Check for given condition
  static bool	check_condition (NaReal stat, int sign, NaReal value);

  // Output mask
  int		mOutStat;

  // Computation gap width or 0 if floating
  unsigned	nGapWidth;

  // Counter of activations inside gap
  unsigned	nGapAct;

  /////////////////////////
  // Temporal statistics //
  /////////////////////////

  NaVector	Sum;
  NaVector	Sum2;

  /////////////////////////
  // Halt condition part //
  /////////////////////////

  int		mHalt;
  struct {
    int		sign;
    NaReal	value;
  }		HaltCond[NaSI_number];

};


//---------------------------------------------------------------------------
#endif
