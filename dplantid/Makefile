PROGRAMS	=dplantid \
		dnnplant

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	cp $(PROGRAMS) $(HOME)/bin

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

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
