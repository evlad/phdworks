PROGRAM	=dobjid

all:	$(PROGRAM)

install:	$(PROGRAM)
	cp $(PROGRAM) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dobjid.cpp \
	NaNNROL.cpp

OBJS	=dobjid.o \
	NaNNROL.o

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
