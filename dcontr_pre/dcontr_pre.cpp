
#pragma hdrstop
#ifndef unix
#include <condefs.h>
#endif /* unix */

//---------------------------------------------------------------------------
// Implementation of the phase #1 of neural network control paradigm (NNCP).
// NNCP - neural network control paradigm. (C)opyright by Eliseev Vladimir
//---------------------------------------------------------------------------
// Phase #1: preliminary NN controller learning on the basis of obtained at
//           phase #0 series (u(t),e(t),x(t)).
//---------------------------------------------------------------------------

#include <math.h>
#include <stdlib.h>

#include "NaLogFil.h"
#include "NaGenerl.h"
#include "NaExcept.h"

#include "NaConfig.h"
#include "NaNNUnit.h"
#include "NaDataIO.h"

#include "NaNNCPL.h"

#include "kbdif.h"

//---------------------------------------------------------------------------
#ifndef unix
USELIB("..\NeuArch\NeuArch.lib");
USELIB("..\NeuArch\PetriNet.lib");
USELIB("..\StaDev\stadev32.lib");
USEUNIT("NaNNCPL.cpp");
USELIB("..\Matrix.041\Matrix.lib");
#endif /* unix */
//---------------------------------------------------------------------------
NaReal  fLA = 0.8;


//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
    NaOpenLogFile("NeuCons1.log");

    try{
        // Neural network description
        NaNeuralNetDescr    nn_descr;

        // Read neural network from file
        NaNNUnit            au_nnc(nn_descr);
        au_nnc.SetInstance("Controller");
        NaConfigPart        *conf_list[] = { &au_nnc };
        NaConfigFile        nnfile(";NeuCon NeuralNet", 1, 0);
        nnfile.AddPartitions(NaNUMBER(conf_list), conf_list);
        nnfile.LoadFromFile("ANNC0.nn");

        // Additional log files
        NaDataFile  *dflog = OpenOutputDataFile("NeuCons1.grf");

        dflog->SetTitle("NN controller preliminary learning (error)");

        dflog->SetVarName(0, "Mean");
        dflog->SetVarName(1, "StdDev");
        dflog->SetVarName(2, "MSE");

        NaNNContrPreLearn       nncpl;

        // Configure nodes
        nncpl.nncontr.set_transfer_func(&au_nnc);
        nncpl.nnteacher.set_nn(&au_nnc);
#ifdef WITH_U
        nncpl.in_u.set_input_filename("u.dat");
#else // WITH_U
        nncpl.delay.set_delay(au_nnc.descr.nInputsRepeat - 1);
        nncpl.delay.set_sleep_value(0.0);
#endif // WITH_U
        nncpl.in_e.set_input_filename("e.dat");
        nncpl.in_x.set_input_filename("x.dat");
        nncpl.nn_x.set_output_filename("x_nn.dat");

        // Link the network
        nncpl.link_net();

        //nncpl.nnteacher.verbose();

        // If error changed for less than given value consider stop learning
        NaReal  fErrPrec = 0.00001;

        fErrPrec = ask_user("Finish error decrease", fErrPrec);

        // If mean value of MSE don't change sign more than given iterations
        // consider start part of learning is over
        int     nMaxConstSignIters = 5, nConstSignIters = 0;

        nMaxConstSignIters =
            ask_user("Number of start iters with const sign of mean",
                     nMaxConstSignIters);


        // Configure learning parameters
        nncpl.nnteacher.lpar.eta = 0.03;
        nncpl.nnteacher.lpar.eta_output = 0.008;
        nncpl.nnteacher.lpar.alpha = 0.0;

        ask_user_lpar(nncpl.nnteacher.lpar);

        // Teach the network iteratively
        NaPNEvent   pnev;
        int         iIter = 0;

#if defined(__MSDOS__) || defined(__WIN32__)
        printf("Press 'q' or 'x' for exit\n");
#endif /* DOS & Win */

        au_nnc.Initialize();

        NaReal  fPrevMSE = 0.0;
        NaReal  fPrevMean = 0.0;

        do{
            ++iIter;
            NaPrintLog("__Iteration_%d__\n", iIter);

            pnev = nncpl.run_net();

            if(pneError != pnev){
                nncpl.statan.print_stat();
            }

            dflog->AppendRecord();
            dflog->SetValue(nncpl.statan.Mean[0], 0);
            dflog->SetValue(nncpl.statan.StdDev[0], 1);
            dflog->SetValue(nncpl.statan.RMS[0], 2);

            //printf("Iteration %-4d, MSE=%g\n", iIter, nncpl.statan.RMS[0]);

            printf("Iteration %-4d, MSE=%g  delta=%-g\n",
                   iIter, nncpl.statan.RMS[0],
                   nncpl.statan.RMS[0] - fPrevMSE);

            if(fPrevMean != 0.0){
                if(NaSIGN(fPrevMean) != NaSIGN(nncpl.statan.Mean[0])
                   && nConstSignIters > nMaxConstSignIters){
                    printf("Mean value changed sign: %g -> %g\n",
                           fPrevMean, nncpl.statan.Mean[0]);

                    nncpl.nnteacher.lpar.eta *= fLA;
                    nncpl.nnteacher.lpar.eta_output *= fLA;

                    printf("Decrease learning speed by %g%%: "
                           "eta=%g eta_output=%g\n", 100 * fLA,
                           nncpl.nnteacher.lpar.eta,
                           nncpl.nnteacher.lpar.eta_output);

                    NaPrintLog("New learning parameters: "
                               "lrate=%g lrate(out)=%g momentum=%g\n",
                               nncpl.nnteacher.lpar.eta,
                               nncpl.nnteacher.lpar.eta_output,
                               nncpl.nnteacher.lpar.alpha);
                }else if(NaSIGN(fPrevMean) == NaSIGN(nncpl.statan.Mean[0])){
                    ++nConstSignIters;
                }
            }
#if 0
            }else{
                nncpl.nnteacher.lpar.eta +=
                    fLA * nncpl.nnteacher.lpar.eta;
                nncpl.nnteacher.lpar.eta_output +=
                    fLA * nncpl.nnteacher.lpar.eta_output;

                printf("Increase learning speed by %g%%: "\
                       "eta=%g eta_output=%g\n", 100 * fLA,
                       nncpl.nnteacher.lpar.eta,
                       nncpl.nnteacher.lpar.eta_output);
            }
#endif

            if(fPrevMSE != 0.0 && fPrevMSE < nncpl.statan.RMS[0]){
                if(ask_user("MSE started to grow; stop learning?")){
                    pnev = pneTerminate;
                    break;
                }
                if(ask_user("Would you like to change learning parameters?",
                            false)){
                    ask_user_lpar(nncpl.nnteacher.lpar);
                }
            }
            if(fPrevMSE != 0.0 &&
               fabs(fPrevMSE - nncpl.statan.RMS[0]) < fErrPrec){
                if(ask_user("MSE decrease is very small; stop learning?")){
                    pnev = pneTerminate;
                    break;
                }
            }

            fPrevMSE = nncpl.statan.RMS[0];
            fPrevMean = nncpl.statan.Mean[0];

            nncpl.nnteacher.update_nn();

        }while(pneDead == pnev);

        NaPrintLog("IMPORTANT: net is dead due to ");
        switch(pnev){
        case pneTerminate:
            NaPrintLog("user break.\n");
            break;

        case pneHalted:
            NaPrintLog("internal halt.\n");
            break;

        case pneDead:
            NaPrintLog("data are exhausted.\n");
            break;

        case pneError:
            NaPrintLog("some error occured.\n");
            break;

        default:
            NaPrintLog("unknown reason.\n");
            break;
        }

        delete dflog;

        nnfile.SaveToFile("ANNC1.nn");
    }
    catch(NaException& ex){
        NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
    }

    return 0;
}


//---------------------------------------------------------------------------
// Ask for real parameter
NaReal
ask_user (const char* szPrompt, NaReal fDefault)
{
    char    enter[30];
    printf("%s <%g>: ", szPrompt, fDefault);
    fgets(enter, sizeof(enter)-1, stdin);
    if('\0' == enter[0])
        return fDefault;
    return strtod(enter, NULL);
}


//---------------------------------------------------------------------------
// Ask for integer parameter
int
ask_user (const char* szPrompt, int iDefault)
{
    char    enter[30];
    printf("%s <%d>: ", szPrompt, iDefault);
    fgets(enter, sizeof(enter)-1, stdin);
    if('\0' == enter[0])
        return iDefault;
    return strtol(enter, NULL, 10);
}


//---------------------------------------------------------------------------
// Ask for boolean parameter
bool
ask_user (const char* szPrompt, bool bDefault)
{
    char    enter[30], *szSelVals;
    if(bDefault){
        szSelVals = "<y>,n";
    }else{
        szSelVals = "y,<n>";
    }

    do{
        printf("%s (%s): ", szPrompt, szSelVals);
        fgets(enter, sizeof(enter)-1, stdin);
    }while('y' != enter[0] && 'n' != enter[0] && '\0' != enter[0]);

    switch(enter[0]){
    case 'y':
        return true;
    case 'n':
        return false;
    }
    return bDefault;
}


//---------------------------------------------------------------------------
// Ask for learning parameters
void
ask_user_lpar (NaStdBackPropParams& lpar)
{
    lpar.eta = ask_user("Learning rate (hidden layers)", lpar.eta);
    lpar.eta_output = ask_user("Learning rate (output layer)",
                               lpar.eta_output);
    lpar.alpha = ask_user("Momentum (inertia)", lpar.alpha);
    fLA = ask_user("Learning acceleration", fLA);

    NaPrintLog("Learning parameters: laccl=%g "
               "lrate=%g lrate(out)=%g momentum=%g\n",
               fLA, lpar.eta, lpar.eta_output, lpar.alpha);
}


//---------------------------------------------------------------------------
