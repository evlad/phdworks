PROGRAM	=wmr0

all:	$(PROGRAM)

install:	$(PROGRAM)
	install -d $(PREFIX)/bin
	install -m 775 -t $(PREFIX)/bin $(PROGRAM)

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=wmr0.cpp

OBJS	=wmr0.o

$(PROGRAM):	$(OBJS) $(LIBS)
	g++ -o $@ $(OBJS) $(LIBS) -ldl -lm

clean:
	-@rm -f $(OBJS) $(PROGRAM)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
