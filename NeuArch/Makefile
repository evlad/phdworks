all:	libpnna.a

CXXFLAGS=$(FLAGS) -fPIC -I../Matrix.041 -I.

SRCS	=NaConLaw.cpp \
	NaConfig.cpp \
	NaDDir.cpp \
	NaDataIO.cpp \
	NaBinrIO.cpp \
	NaDynAr.cpp \
	NaExcept.cpp \
	NaInfoSt.cpp \
	NaLiNois.cpp \
	NaLinCon.cpp \
	NaLogFil.cpp \
	NaMath.cpp \
	NaMatrix.cpp \
	NaNDescr.cpp \
	NaNNCon.cpp \
	NaNNLrn.cpp \
	NaNNPObj.cpp \
	NaNNUnit.cpp \
	NaPCnInp.cpp \
	NaPCnOut.cpp \
	NaPID.cpp \
	NaPNAct.cpp \
	NaPNBu21.cpp \
	NaPNChPt.cpp \
	NaPNCmp.cpp \
	NaPNCnst.cpp \
	NaPNDely.cpp \
	NaPNFIn.cpp \
	NaPNFOut.cpp \
	NaPNFetc.cpp \
	NaPNGen.cpp \
	NaPNKalm.cpp \
	NaPNRand.cpp \
	NaPNStat.cpp \
	NaPNSum.cpp \
	NaPNSwap.cpp \
	NaPNSwit.cpp \
	NaPNTchr.cpp \
	NaPNTimD.cpp \
	NaPNTime.cpp \
	NaPNTran.cpp \
	NaPNTrig.cpp \
	NaPNLAnd.cpp \
	NaPetCn.cpp \
	NaPetNet.cpp \
	NaPetNod.cpp \
	NaPetri.cpp \
	NaPlotIO.cpp \
	NaQProp.cpp \
	NaRandom.cpp \
	NaSSCtrl.cpp \
	NaSSPlan.cpp \
	NaStdBPE.cpp \
	NaStrOps.cpp \
	NaSysSch.cpp \
	NaTextIO.cpp \
	NaTimer.cpp \
	NaTrFunc.cpp \
	NaCoFunc.cpp \
	NaCuFunc.cpp \
	NaExFunc.cpp \
	NaUnit.cpp \
	NaVector.cpp \
	NaParams.cpp \
	NaPNDerv.cpp \
	NaPNQIn.cpp \
	NaPNQOut.cpp \
	NaPNSkip.cpp \
	NaPNFill.cpp \
	NaPNNNUn.cpp \
	NaPNCuSu.cpp \
	NaPNWatc.cpp \
	kbdif.cpp

#	NaStaIO.cpp \
#	PNPrint.cpp \
#	PNPrinter.cpp \
#	PNPrintr.cpp \
#	PNRandom.cpp

OBJS	=$(SRCS:.cpp=.o)

TestNN:	TestNN.o libpnna.a
	$(LINK.cpp) -o $@ TestNN.o libpnna.a ../Matrix.041/libmatrix.a -lm

TestTF:	TestTF.o libpnna.a
	$(LINK.cpp) -o $@ TestTF.o libpnna.a ../Matrix.041/libmatrix.a -lm

TestCF:	TestCF.o libpnna.a
	$(LINK.cpp) -o $@ TestCF.o libpnna.a ../Matrix.041/libmatrix.a -ldl -lm

TestQIO:	TestQIO.o libpnna.a
	$(LINK.cpp) -o $@ TestQIO.o libpnna.a ../Matrix.041/libmatrix.a -lm

clean:
	-@rm -f $(OBJS)

libpnna.a:	$(OBJS)
	ar -ruv $@ $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
