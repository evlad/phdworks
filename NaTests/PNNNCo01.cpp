/* PNNNCo01.cpp */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <NaPetNet.h>
#include <NaPNNNCo.h>
#include <NaPNFIn.h>
#include <NaPNFOut.h>

#define TESTNAME	"PNNNCo01"

int
main (int argc, char* argv[])
{
    NaOpenLogFile(TESTNAME ".log");
    int nTestCase = (argc > 1)? atoi(argv[1]): 1;

    NaPrintLog("!! " TESTNAME " - basic functional tests for NaPNNNController\n");

    NaPetriNet	net(TESTNAME);
    NaPNFileInput	fin("fin");
    NaPNFileOutput	fout("fout");
    NaPNNNController	nnc("nnc");

    NaPrintLog("!! Test case %d\n", nTestCase);

    try{
	fout.set_output_filename(TESTNAME "_output.dat");
	fin.set_input_filename(TESTNAME "_input.dat");

	NaNNUnit	nncunit;
	char		szNNC[100];
	sprintf(szNNC, "%s-%d.nn", TESTNAME, nTestCase);
	nncunit.Load(szNNC);
	nnc.set_nn_unit(&nncunit);

	net.add(&nnc);
	net.link_nodes(&fin, &nnc, &fout, NULL);

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
