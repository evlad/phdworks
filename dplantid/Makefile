PROGRAMS	=dplantid \
		dnnplant

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	install -d $(PREFIX)/bin
	install -m 775 -t $(PREFIX)/bin $(PROGRAMS)

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dplantid.cpp \
	dnnplant.cpp \
	NaNNRPL.cpp

OBJS	=$(common_OBJS) \
	$(dplantid_OBJS) \
	$(dnnplant_OBJS)

common_OBJS	=NaNNRPL.o

dplantid_OBJS	=dplantid.o

dnnplant_OBJS	=dnnplant.o

dplantid:	$(dplantid_OBJS) $(common_OBJS) $(LIBS)
	g++ -o $@ $(dplantid_OBJS) $(common_OBJS) $(LIBS) -lm

dnnplant:	$(dnnplant_OBJS) $(common_OBJS) $(LIBS)
	g++ -o $@ $(dnnplant_OBJS) $(common_OBJS) $(LIBS) -lm

clean:
	-@rm -f $(OBJS) $(PROGRAMS)

dplantid.o:	NaNNRPL.h
dnnplant.o:	NaNNRPL.h
NaNNRPL.o:	NaNNRPL.h

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
