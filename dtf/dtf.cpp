/* dtf.cpp */
static char rcsid[] = "$Id: dtf.cpp,v 1.1 2001-04-01 19:40:16 vlad Exp $";

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include <NaLogFil.h>
#include <NaGenerl.h>
#include <NaExcept.h>

#include <NaConfig.h>
#include <NaTrFunc.h>
#include <NaDataIO.h>


/***********************************************************************
 * Feed input series to given discrete transfer function and put the
 * result to output series.
 ***********************************************************************/
main (int argc, char* argv[])
{
  if(argc != 4)
    {
      fprintf(stderr, "Error: need 3 arguments\n");
      printf("Usage: dtf DiscrTrFunc InSeries OutSeries\n");
      return 1;
    }

  char	*dtf_file = argv[1];
  char	*in_file = argv[2];
  char	*out_file = argv[3];

  NaOpenLogFile("dtf.log");

  try{
    NaTransFunc		dtf;
    NaConfigPart	*conf_list[] = { &dtf };
    NaConfigFile	conf_file(";NeuCon transfer", 1, 0);
    conf_file.AddPartitions(NaNUMBER(conf_list), conf_list);
    conf_file.LoadFromFile(dtf_file);

    NaDataFile	*dfIn = OpenInputDataFile(in_file);
    NaDataFile	*dfOut = OpenOutputDataFile(out_file);

    dfIn->GoStartRecord();
    dtf.Reset();
    do{
      NaReal	fIn, fOut;
      fIn = dfIn->GetValue();

      dtf.Function(&fIn, &fOut);

      dfOut->AppendRecord();
      dfOut->SetValue(fOut);
    }while(dfIn->GoNextRecord());

    delete dfOut;
    delete dfIn;
  }
  catch(NaException& ex){
    NaPrintLog("EXCEPTION: %s\n", NaExceptionMsg(ex));
  }

  return 0;
}
