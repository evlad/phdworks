PROGRAMS=UNGen MakeNN Distr2D StatAn ResetNN FileCvt EvalNN TrainNN

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	cp $(PROGRAMS) $(HOME)/bin

CCC	=g++

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a

StatAn:	StatAn.o $(LIBS)
	$(CCC) -o $@ $@.o $(LDFLAGS) $(LIBS)

Distr2D:	Distr2D.o $(LIBS)
	$(CCC) -o $@ Distr2D.o $(LDFLAGS) $(LIBS)

MakeNN:	MakeNN.o $(LIBS)
	$(CCC) -o $@ MakeNN.o $(LDFLAGS) $(LIBS)

ResetNN:	ResetNN.o $(LIBS)
	$(CCC) -o $@ ResetNN.o $(LDFLAGS) $(LIBS)

EvalNN:	EvalNN.o $(LIBS)
	$(CCC) -o $@ EvalNN.o $(LDFLAGS) $(LIBS)

TrainNN:	TrainNN.o $(LIBS)
	$(CCC) -o $@ TrainNN.o $(LDFLAGS) $(LIBS)

UNGen:	UNGen.o $(LIBS)
	$(CCC) -o $@ UNGen.o $(LDFLAGS) $(LIBS)

FileCvt:	FileCvt.o $(LIBS)
	$(CCC) -o $@ FileCvt.o $(LDFLAGS) $(LIBS)

clean:
	-@rm -f *.o $(PROGRAMS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
