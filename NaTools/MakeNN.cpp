
#ifndef unix
#pragma hdrstop
#include <condefs.h>
#endif /* unix */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#if defined(__MSDOS__) || defined(__WIN32__)
#include <io.h>     /* for access() */
#   ifndef F_OK
#       define F_OK        0
#   endif /* F_OK */
#endif /* defined(__MSDOS__) || defined(__WIN32__) */

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>
#include <NaConfig.h>
#include <NaNNUnit.h>
#include <kbdif.h>

//---------------------------------------------------------------------------
// Create neural network file with randomized weights
// (C)opyright by Eliseev Vladimir
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
#ifndef unix
USELIB("NeuArch.lib");
#endif /* unix */

//---------------------------------------------------------------------------
// Ask for integer parameter
int     ask_user (const char* szPrompt, int iDefault);

//---------------------------------------------------------------------------
#pragma argsused
int main(int argc, char **argv)
{
  int     argn = argc - 1;
  char    **args = argv + 1;
  char    *fname, deffname[] = "new.nn";
  char    *nname, defnname[] = "Undefined";

  try{
    NaNeuralNetDescr    nnd;    // Default NN description 
    NaConfigFile        nnfile(";NeuCon NeuralNet", 1, 0);

    printf("Neural network maker %s\n", nnfile.Magic());
    printf("Usage: MakeNN.exe [ File.nn [ NameOfNN ] ]\n");


    fname = ask_name("Target filename", argn > 0? args[0]: deffname);

    // Some default NN description
    NaNNUnit            nnu(nnd);

    NaConfigPart        *conf_list[] = { &nnu };
    nnfile.AddPartitions(NaNUMBER(conf_list), conf_list);

    // Check for existant file
    if(!access(fname, F_OK)){
        // File is exist
        printf("Changing NN file '%s'\n", fname);

        // Read neural network from file
        nnfile.LoadFromFile(fname);
    }else{
        // New file
        printf("Creating new NN file '%s'\n", fname);
    }

    nname = ask_name("Target filename", argn > 1? args[1]: defnname);

    nnu.SetInstance(nname);

    // Ask for NN description
    nnd.nInputsNumber = ask_user("Input dimension", (int)nnd.nInputsNumber);
    nnd.nInputsRepeat = ask_user("Input repeats", (int)nnd.nInputsRepeat);
    nnd.nOutNeurons = ask_user("Output dimension", (int)nnd.nOutNeurons);
    nnd.nOutputsRepeat = ask_user("Output repeats", (int)nnd.nOutputsRepeat);
    nnd.nFeedbackDepth = ask_user("Feedback depth", (int)nnd.nFeedbackDepth);

    nnd.eLastActFunc =
        (NaActFuncKind) ask_user("Output activation (0-linear; 1-sigmoid)",
                                 (int)nnd.eLastActFunc);
    nnd.nHidLayers = ask_user("Number of hidden layers (0-3)",
			      (int)nnd.nHidLayers);
    if(nnd.nHidLayers > MAX_HIDDEN){
        printf("Not more than %u layers are allowed.\n", MAX_HIDDEN);
        nnd.nHidLayers = MAX_HIDDEN;
    }
    unsigned    iLayer;
    for(iLayer = 0; iLayer < nnd.nHidLayers; ++iLayer){
        // Ask for number of neurons in given layer
        char    prompt[100];
        sprintf(prompt, "Hidden layer #%u", iLayer);
        nnd.nHidNeurons[iLayer] = ask_user(prompt,
					   (int)nnd.nHidNeurons[iLayer]);
    }

    nnu.AssignDescr(nnd);

    nnu.Initialize();

    // Store neural network to file
    nnfile.SaveToFile(fname);
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}

//---------------------------------------------------------------------------
