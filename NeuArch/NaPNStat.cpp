/* NaPNStat.cpp */
static char rcsid[] = "$Id: NaPNStat.cpp,v 1.3 2001-12-11 21:20:48 vlad Exp $";
//---------------------------------------------------------------------------

#include <math.h>
#include <stdio.h>

#include "NaPNStat.h"



//---------------------------------------------------------------------------
// Create node for Petri network
NaPNStatistics::NaPNStatistics (const char* szNodeName)
: NaPetriNode(szNodeName),
  ////////////////
  // Connectors //
  ////////////////
  signal(this, "signal")
{
    // Nothing to do
}


//---------------------------------------------------------------------------

///////////////////
// Node specific //
///////////////////

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

///////////////////////
// Phases of network //
///////////////////////

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
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNStatistics::action ()
{
    unsigned    i;
    NaVector    &x = signal.data();

    for(i = 0; i < x.dim(); ++i){
        Sum[i] += x[i];
        Sum2[i] += x[i] * x[i];

        if(activations() == 0){
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

	Mean[i] = Sum[i] / (1 + activations());
	RMS[i] = Sum2[i] / (1 + activations());
	StdDev[i] = sqrt(RMS[i] - Mean[i] * Mean[i]);

    }// for each item of input dimension
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
