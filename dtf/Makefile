PROGRAMS	=dtf d2ts drand dwtest dmse dcorr dsum

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	cp $(PROGRAMS) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a


SRCS	=dtf.cpp \
	d2ts.cpp \
	drand.cpp \
	dwtest.cpp \
	dmse.cpp \
	dcorr.cpp \
	dsum.cpp

OBJS	=$(dtf_OBJS) $(d2ts_OBJS) $(drand_OBJS) $(dwtest_OBJS) \
	$(dmse_OBJS) $(dcorr_OBJS)

dtf_OBJS	=dtf.o
dtf:	$(dtf_OBJS) $(LIBS)
	g++ -o $@ $(dtf_OBJS) $(LIBS) -lm

d2ts_OBJS	=d2ts.o
d2ts:	$(d2ts_OBJS) $(LIBS)
	g++ -o $@ $(d2ts_OBJS) $(LIBS) -lm

drand_OBJS	=drand.o
drand:	$(drand_OBJS) $(LIBS)
	g++ -o $@ $(drand_OBJS) $(LIBS) -lm

dwtest_OBJS	=dwtest.o
dwtest:	$(dwtest_OBJS) $(LIBS)
	g++ -o $@ $(dwtest_OBJS) $(LIBS) -lm

dmse_OBJS	=dmse.o
dmse:	$(dmse_OBJS) $(LIBS)
	g++ -o $@ $(dmse_OBJS) $(LIBS) -lm

dcorr_OBJS	=dcorr.o
dcorr:	$(dcorr_OBJS) $(LIBS)
	g++ -o $@ $(dcorr_OBJS) $(LIBS) -lm

dsum_OBJS	=dsum.o
dsum:	$(dsum_OBJS) $(LIBS)
	g++ -o $@ $(dsum_OBJS) $(LIBS) -lm

clean:
	-@rm -f $(OBJS) $(PROGRAMS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
