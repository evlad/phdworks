all:	libpnna.a

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I.

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
	NaNNet.cpp \
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
	NaUnit.cpp \
	NaVector.cpp \
	NaParams.cpp \
	NaPNDerv.cpp \
	NaPNQIn.cpp \
	NaPNQOut.cpp \
	NaPNSkip.cpp \
	kbdif.cpp

#	NaStaIO.cpp \
#	PNPrint.cpp \
#	PNPrinter.cpp \
#	PNPrintr.cpp \
#	PNRandom.cpp

OBJS	=NaConLaw.o \
	NaConfig.o \
	NaDDir.o \
	NaDataIO.o \
	NaBinrIO.o \
	NaDynAr.o \
	NaExcept.o \
	NaInfoSt.o \
	NaLiNois.o \
	NaLinCon.o \
	NaLogFil.o \
	NaMath.o \
	NaMatrix.o \
	NaNDescr.o \
	NaNNCon.o \
	NaNNLrn.o \
	NaNNPObj.o \
	NaNNUnit.o \
	NaNNet.o \
	NaPCnInp.o \
	NaPCnOut.o \
	NaPID.o \
	NaPNAct.o \
	NaPNBu21.o \
	NaPNChPt.o \
	NaPNCmp.o \
	NaPNCnst.o \
	NaPNDely.o \
	NaPNFIn.o \
	NaPNFOut.o \
	NaPNFetc.o \
	NaPNGen.o \
	NaPNKalm.o \
	NaPNRand.o \
	NaPNStat.o \
	NaPNSum.o \
	NaPNSwap.o \
	NaPNSwit.o \
	NaPNTchr.o \
	NaPNTimD.o \
	NaPNTime.o \
	NaPNTran.o \
	NaPNTrig.o \
	NaPNLAnd.o \
	NaPetCn.o \
	NaPetNet.o \
	NaPetNod.o \
	NaPetri.o \
	NaPlotIO.o \
	NaQProp.o \
	NaRandom.o \
	NaSSCtrl.o \
	NaSSPlan.o \
	NaStdBPE.o \
	NaStrOps.o \
	NaSysSch.o \
	NaTextIO.o \
	NaTimer.o \
	NaTrFunc.o \
	NaUnit.o \
	NaVector.o \
	NaParams.o \
	NaPNDerv.o \
	NaPNQIn.o \
	NaPNQOut.o \
	NaPNSkip.o \
	kbdif.o

TestNN:	TestNN.o libpnna.a
	$(LINK.cpp) -o $@ TestNN.o libpnna.a ../Matrix.041/libmatrix.a -lm

TestTF:	TestTF.o libpnna.a
	$(LINK.cpp) -o $@ TestTF.o libpnna.a ../Matrix.041/libmatrix.a -lm

TestQIO:	TestQIO.o libpnna.a
	$(LINK.cpp) -o $@ TestQIO.o libpnna.a ../Matrix.041/libmatrix.a -lm

clean:
	-@rm -f $(OBJS)

libpnna.a:	$(OBJS)
	ar -ruv $@ $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
