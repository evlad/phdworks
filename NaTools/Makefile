PROGRAMS=UNGen MakeNN Distr2D StatAn

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	cp $(PROGRAMS) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a

StatAn:	StatAn.o $(LIBS)
	g++ -o $@ $@.o $(LDFLAGS) $(LIBS)

Distr2D:	Distr2D.o $(LIBS)
	g++ -o $@ Distr2D.o $(LDFLAGS) $(LIBS)

MakeNN:	MakeNN.o $(LIBS)
	g++ -o $@ MakeNN.o $(LDFLAGS) $(LIBS)

UNGen:	UNGen.o $(LIBS)
	g++ -o $@ UNGen.o $(LDFLAGS) $(LIBS)

clean:
	-@rm -f *.o $(PROGRAMS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
