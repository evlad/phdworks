/* PNDely01.cpp */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <NaPetNet.h>
#include <NaPNDely.h>
#include <NaPNFIn.h>
#include <NaPNFOut.h>

#define TESTNAME	"PNDely01"

int
main (int argc, char* argv[])
{
    NaOpenLogFile(TESTNAME ".log");
    int nTestCase = (argc > 1)? atoi(argv[1]): 1;

    NaPrintLog("!! " TESTNAME " - basic functional tests for NaPNDelay\n");

    NaPetriNet	net(TESTNAME);
    NaPNFileInput	fin("fin");
    NaPNFileOutput	fout("fout");
    NaPNDelay		delay("delay");

    NaPrintLog("!! Test case %d\n", nTestCase);
    try{
	fin.set_input_filename(TESTNAME "_input.dat");
	fout.set_output_filename(TESTNAME "_output.dat");
	unsigned int delays[] = {0, 2, 4};

	switch(nTestCase) {
	case 1:
	    NaPrintLog("!! Purpose: no delay\n");
	    delay.set_delay(0);
	    break;
	case 2:
	    NaPrintLog("!! Purpose: simple delay\n");
	    delay.set_delay(2);
	    break;
	case 3:
	    NaPrintLog("!! Purpose: simple delay with sleep value\n");
	    delay.set_delay(2);
	    delay.set_sleep_value(5);
	    break;
	case 4:
	    NaPrintLog("!! Purpose: simple delay with 1st sleep value\n");
	    delay.set_delay(2);
	    delay.set_sleep_value_1st();
	    break;
	case 5:
	    NaPrintLog("!! Purpose: selected delays\n");
	    delay.set_delay(sizeof(delays)/sizeof(delays[0]), delays);
	    break;
	case 6:
	    NaPrintLog("!! Purpose: selected delays with sleep value\n");
	    delay.set_delay(sizeof(delays)/sizeof(delays[0]), delays);
	    delay.set_sleep_value(5);
	    break;
	case 7:
	    NaPrintLog("!! Purpose: selected delays with 1st sleep value\n");
	    delay.set_delay(sizeof(delays)/sizeof(delays[0]), delays);
	    delay.set_sleep_value_1st();
	    break;
	default:
	    NaPrintLog("!! Unknown test case %d\n", nTestCase);
	    return 1;
	}

	net.link_nodes(&fin, &delay, &fout, NULL);

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
