/* TestNN.cpp */
static char rcsid[] = "$Id: TestNN.cpp,v 1.2 2001-05-15 06:02:24 vlad Exp $";
//---------------------------------------------------------------------------

#include "NaNNUnit.h"
#include "NaConfig.h"
#include "NaExcept.h"


main (int argc, char* argv[])
{
  if(2 != argc)
    {
      fprintf(stderr, "Usage: TestNN File.nn\n");
      return 1;
    }

  try{
    NaNeuralNetDescr	nndescr;
    NaNNUnit		au_nn(nndescr);

    // Configuration files
    NaConfigPart		*nn_conf_list[] = { &au_nn };
    NaConfigFile		nnfile(";NeuCon NeuralNet", 1, 1);
    nnfile.AddPartitions(NaNUMBER(nn_conf_list), nn_conf_list);
    nnfile.LoadFromFile(argv[1]);

    au_nn.descr.PrintLog();
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
