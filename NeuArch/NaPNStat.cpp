/* NaPNStat.cpp */
static char rcsid[] = "$Id: NaPNStat.cpp,v 1.4 2001-12-12 22:38:20 vlad Exp $";
//---------------------------------------------------------------------------

#include <math.h>
#include <stdio.h>

#include "NaPNStat.h"


static 	char	*szId[NaSI_number] = {
  "MEAN", "RMS", "STDDEV", "MAX", "MIN", "ABS"
};
static char	*szSign[3] = {
  "<", "=", ">"
};


//---------------------------------------------------------------------------
// Create node for Petri network
NaPNStatistics::NaPNStatistics (const char* szNodeName)
  : NaPetriNode(szNodeName), mOutStat(NaSM_ALL), mHalt(0), nGapWidth(0),
  ////////////////
  // Connectors //
  ////////////////
  signal(this, "signal"),
  stat(this, "stat")
{
    // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

//---------------------------------------------------------------------------
// Confugure computation rule as continuos or floating gap
void
NaPNStatistics::set_floating_gap (unsigned gap_width)
{
  check_tunable();

  nGapWidth = gap_width;
}


//---------------------------------------------------------------------------
// Confugure output values
void
NaPNStatistics::configure_output (int stat_mask)
{
  check_tunable();

  mOutStat = stat_mask;
}


//---------------------------------------------------------------------------
// Setup net stop condition:
// sign<0 --> stop if statistics value is less than value
// sign=0 --> stop if statistics value is equal than value
// sign>0 --> stop if statistics value is greater than value
void
NaPNStatistics::halt_condition (int stat_id, int sign, NaReal value)
{
  if(stat_id < NaSI_MEAN || stat_id > NaSI_ABS){
    NaPrintLog("NaPNStatistics::halt_condition(): unknown id=%d\n", stat_id);
  }

  mHalt |= NaSIdToMask(stat_id);
  HaltCond[stat_id].value = value;

  if(sign < 0)
    HaltCond[stat_id].sign = LESS_THAN;
  else if(sign > 0)
    HaltCond[stat_id].sign = GREATER_THAN;
  else
    HaltCond[stat_id].sign = EQUAL_TO;
}


//---------------------------------------------------------------------------
// Print to the log statistics
void
NaPNStatistics::print_stat (const char* szTitle)
{
    if(NULL == szTitle){
        NaPrintLog("Statistics of '%s':\n", name());
    }else{
        NaPrintLog("%s\n", szTitle);
    }
    NaPrintLog("\tMin\tMax\tMean\tStdDev\tRMS\tVolume\n");
    if(Mean.dim() == 1){
        NaPrintLog("%s:\t%g\t%g\t%g\t%g\t%g\t%u\n", name(),
		   Min[0], Max[0], Mean[0], StdDev[0], RMS[0], activations());
    }else for(unsigned i = 0; i < Mean.dim(); ++i){
      NaPrintLog("%s%u:\t%g\t%g\t%g\t%g\t%g\t%u\n", name(), i+1,
		 Min[i], Max[i], Mean[i], StdDev[i], RMS[i], activations());
    }
}


//---------------------------------------------------------------------------
// Check for given condition
bool
NaPNStatistics::check_condition (NaReal stat, int sign, NaReal value)
{
  if(sign < 0)
    return stat < value;
  else if(sign > 0)
    return stat > value;

  return stat == value;
}


//---------------------------------------------------------------------------

///////////////////////
// Phases of network //
///////////////////////

//---------------------------------------------------------------------------
// 2. Link connectors inside the node
void
NaPNStatistics::relate_connectors ()
{
    // n - number of needed statistics
    int	id, n = 0;
    for(id = 0; id < NaSI_number; ++id){
      if(mOutStat & NaSIdToMask(id))
	++n;
    }
    stat.data().new_dim(n);
}


//---------------------------------------------------------------------------
// 4. Allocate resources for internal usage
void
NaPNStatistics::allocate_resources ()
{
    Mean.new_dim(signal.data().dim());
    StdDev.new_dim(signal.data().dim());
    RMS.new_dim(signal.data().dim());
    Min.new_dim(signal.data().dim());
    Max.new_dim(signal.data().dim());

    Sum.new_dim(signal.data().dim());
    Sum2.new_dim(signal.data().dim());
}


//---------------------------------------------------------------------------
// 5. Verification to be sure all is OK (true)
bool
NaPNStatistics::verify ()
{
    return Mean.dim() == signal.data().dim()
        && StdDev.dim() == signal.data().dim()
        && RMS.dim() == signal.data().dim()
        && Min.dim() == signal.data().dim()
        && Max.dim() == signal.data().dim()
        && Sum.dim() == signal.data().dim()
        && Sum2.dim() == signal.data().dim();
}


//---------------------------------------------------------------------------
// 6. Initialize node activity and setup starter flag if needed
void
NaPNStatistics::initialize (bool& starter)
{
    Mean.init_zero();
    RMS.init_zero();
    StdDev.init_zero();
    Min.init_zero();
    Max.init_zero();

    Sum.init_zero();
    Sum2.init_zero();

    nGapAct = 0;

    if(is_verbose()){
      if(nGapWidth)
	NaPrintLog("Statistics node '%s' has floating gap %u computation\n",
		   name(), nGapWidth);
      else
	NaPrintLog("Statistics node '%s' has continuous computation\n",
		   name());
      if(mHalt & NaSM_ALL){
	int	id;

	NaPrintLog("  and has next halt conditions:\n");
	for(id = 0; id < NaSI_number; ++id){
	  if(mHalt & NaSIdToMask(id))
	    NaPrintLog("  %s[0] %s %g\n", szId[id],
		       szSign[1 + HaltCond[id].sign], HaltCond[id].value);
	}
      }else
	NaPrintLog("  and does not have halt conditions.\n");
    }
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNStatistics::action ()
{
  unsigned    i;
  NaVector    &x = signal.data();

  if(nGapAct >= nGapWidth && nGapWidth > 0)
    {
      // prepare next gap session
      Mean.init_zero();
      RMS.init_zero();
      StdDev.init_zero();
      Min.init_zero();
      Max.init_zero();

      Sum.init_zero();
      Sum2.init_zero();

      // reset activations counter
      nGapAct = 0;
    }

  // one more activation
  ++nGapAct;

  // compute basic statistics
  for(i = 0; i < x.dim(); ++i){
    Sum[i] += x[i];
    Sum2[i] += x[i] * x[i];

    if(nGapAct == 1){
      Min[i] = x[i];
      Max[i] = x[i];
    }else{
      if(x[i] < Min[i]){
	Min[i] = x[i];
      }
      if(x[i] > Max[i]){
	Max[i] = x[i];
      }
    }

    Mean[i] = Sum[i] / nGapAct;
    RMS[i] = Sum2[i] / nGapAct;
    StdDev[i] = sqrt(RMS[i] - Mean[i] * Mean[i]);

  }// for each item of input dimension

  // compute final statistics
  NaReal	fAbs;
  if(fabs(Min[0]) > fabs(Max[0]))
    fAbs = fabs(Min[0]);
  else
    fAbs = fabs(Max[0]);

  int	id, j = 0;

  // put needed statistics to output
  for(id = 0; id < NaSI_number; ++id){
    switch(mOutStat & NaSIdToMask(id))
      {
      case NaSM_MEAN:	stat.data()[j++] = Mean[0];	break;
      case NaSM_RMS:	stat.data()[j++] = RMS[0];	break;
      case NaSM_STDDEV:	stat.data()[j++] = StdDev[0];	break;
      case NaSM_MAX:	stat.data()[j++] = Max[0];	break;
      case NaSM_MIN:	stat.data()[j++] = Min[0];	break;
      case NaSM_ABS:	stat.data()[j++] = fAbs;	break;
      }
  }

  // check some statistics for halt condition
  if(nGapAct >= nGapWidth && nGapWidth > 0)
    {
      int	mHaltedBy = 0;
      for(id = 0; id < NaSI_number; ++id){
	switch(mHalt & NaSIdToMask(id))
	  {
	  case NaSM_MEAN:
	    mHaltedBy |=
	      check_condition(Mean[0], HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  case NaSM_RMS:
	    mHaltedBy |=
	      check_condition(RMS[0], HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  case NaSM_STDDEV:
	    mHaltedBy |=
	      check_condition(StdDev[0], HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  case NaSM_MAX:
	    mHaltedBy |=
	      check_condition(Max[0], HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  case NaSM_MIN:
	    mHaltedBy |=
	      check_condition(Min[0], HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  case NaSM_ABS:
	    mHaltedBy |=
	      check_condition(fAbs, HaltCond[id].sign, HaltCond[id].value)
	      ? NaSIdToMask(id) : 0;
	    break;
	  }// switch
      }// for each id

      // if any of halt flags is true...
      if(mHaltedBy & NaSM_ALL){
	if(is_verbose()){
	  NaPrintLog("Statistics node '%s' caused halt due to:\n", name());
	  for(id = 0; id < NaSI_number; ++id){
	    if(mHaltedBy & NaSIdToMask(id))
	      NaPrintLog("  %s[0] %s %g\n", szId[id],
			 szSign[1 + HaltCond[id].sign], HaltCond[id].value);
	  }
	}

	// some halt condition results true
	halt();
      }
    }
}


//---------------------------------------------------------------------------
// 9. Finish data processing by the node (if activate returned true)
void
NaPNStatistics::post_action ()
{
  signal.commit_data();

  if(nGapAct >= nGapWidth && nGapWidth > 0
     || 0 == nGapWidth)
    // commit data each activations (continuous computation) or at the
    // end of each gap
    stat.commit_data();
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
