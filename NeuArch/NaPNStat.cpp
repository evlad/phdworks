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
    check_tunable();

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
        && Max.dim() == signal.data().dim();
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
}


//---------------------------------------------------------------------------
// 8. True action of the node (if activate returned true)
void
NaPNStatistics::action ()
{
    unsigned    i;
    NaVector    &x = signal.data();

    for(i = 0; i < x.dim(); ++i){
        Mean[i] += x[i];
        RMS[i] += x[i] * x[i];
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
    }// for each item of input dimension
}


//---------------------------------------------------------------------------
// 10. Deallocate resources and close external data
void
NaPNStatistics::release_and_close ()
{
    // Complete computations
    if(0 != activations()){
        unsigned    i;
        NaVector    &x = signal.data();

        for(i = 0; i < x.dim(); ++i){
            Mean[i] /= activations();
            RMS[i] /= activations();
            StdDev[i] = sqrt(RMS[i] - Mean[i] * Mean[i]);
        }
    }
}


//---------------------------------------------------------------------------
#pragma package(smart_init)
