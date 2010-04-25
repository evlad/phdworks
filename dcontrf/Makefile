PROGRAM	=dcontrf

all:	$(PROGRAM) NaNNOCL2.o

install:	$(PROGRAM)
	cp $(PROGRAM) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dcontrf.cpp \
	NaNNOCL.cpp \
	NaNNOCL2.cpp

OBJS	=dcontrf.o \
	NaNNOCL.o

NaNNOCL2.o: NaNNOCL2.h

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) $(LDFLAGS) -ldl -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
