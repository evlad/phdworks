PROGRAM	=dcontrf

all:	$(PROGRAM)

install:	$(PROGRAM)
	cp $(PROGRAM) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dcontrf.cpp \
	NaNNOCL.cpp

OBJS	=dcontrf.o \
	NaNNOCL.o

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
