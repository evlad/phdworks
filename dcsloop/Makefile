PROGRAM	=dcsloop

all:	$(PROGRAM)

install:	$(PROGRAM)
	cp $(PROGRAM) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dcsloop.cpp \
	NaCSM.cpp

OBJS	=dcsloop.o \
	NaCSM.o

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) -ldl -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
