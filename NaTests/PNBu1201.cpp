/* PNBu1201.cpp */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <NaPetNet.h>
#include <NaPNBu12.h>
#include <NaPNFIn.h>
#include <NaPNFOut.h>

#define TESTNAME	"PNBu1201"

int
main (int argc, char* argv[])
{
    NaOpenLogFile(TESTNAME ".log");
    int nTestCase = (argc > 1)? atoi(argv[1]): 1;

    NaPrintLog("!! " TESTNAME " - basic functional tests for NaPNBus1i2o\n");

    NaPetriNet	net(TESTNAME);
    NaPNFileInput	fin("fin");
    NaPNFileOutput	fout1("fout1");
    NaPNFileOutput	fout2("fout2");
    NaPNBus1i2o		split("split");

    NaPrintLog("!! Test case %d\n", nTestCase);
    try{
	fin.set_input_filename(TESTNAME "_input.dat");
	fout1.set_output_filename(TESTNAME "_output1.dat");
	fout2.set_output_filename(TESTNAME "_output2.dat");

	switch(nTestCase) {
	case 1:
	    NaPrintLog("!! Purpose: split to the 1st and the rest\n");
	    split.set_out_dim_proportion(1, 0);
	    break;
	case 2:
	    NaPrintLog("!! Purpose: split to the last and the rest\n");
	    split.set_out_dim_proportion(0, 1);
	    break;
	case 3:
	    NaPrintLog("!! Purpose: split into one to two ratio\n");
	    split.set_out_dim_proportion(1, 2);
	    break;
	case 4:
	    NaPrintLog("!! Purpose: split to equal parts\n");
	    split.set_out_dim_proportion(1, 1);
	    break;
	default:
	    NaPrintLog("!! Unknown test case %d\n", nTestCase);
	    return 1;
	}

	net.link_nodes(&fin, &split, NULL);
	net.link(&split.out1, &fout1.in);
	net.link(&split.out2, &fout2.in);

        // Prepare petri net engine
        if(!net.prepare(true)){
            NaPrintLog("IMPORTANT: verification failed!\n");
	    return 2;
        }
        else{
            NaPNEvent       pnev;

            // Activities cycle
            do{
                pnev = net.step_alive();

            }while(pneAlive == pnev);

            net.terminate();
        }
    }
    catch(NaException& ex){
        NaPrintLog("EXCEPTION at runtime phase: %s\n", NaExceptionMsg(ex));
	return 3;
    }

    return 0;
}
