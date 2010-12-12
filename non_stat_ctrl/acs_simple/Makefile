PROGRAM	=acstest

NADIR	=../..

all:	$(PROGRAM)

install:	$(PROGRAM)
	cp $(PROGRAM) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I$(NADIR)/Matrix.041 -I$(NADIR)/NeuArch

LIBS	=$(NADIR)/NeuArch/libpnna.a $(NADIR)/Matrix.041/libmatrix.a


SRCS	=acs_simple.cpp

OBJS	=$(SRCS:.cpp=.o)

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) -ldl -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
