PROGRAMS	=dtf d2ts drand dwtest dwtest2 dmse dcorr dsum dstat djacob \
		dsin dmean dstddev

all:	$(PROGRAMS)

install:	$(PROGRAMS)
	cp $(PROGRAMS) $(HOME)/bin

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

SYSLIBS	=-ldl -lm
LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a

SRCS	=dtf.cpp \
	d2ts.cpp \
	drand.cpp \
	dwtest.cpp \
	dwtest2.cpp \
	dmse.cpp \
	dcorr.cpp \
	dsum.cpp \
	dstat.cpp \
	djacob.cpp \
	dstddev.cpp \
	dsin.cpp \
	dmean.cpp

OBJS	=$(dtf_OBJS) $(d2ts_OBJS) $(drand_OBJS) $(dwtest_OBJS) \
	$(dmse_OBJS) $(dcorr_OBJS) $(dsum_OBJS) $(dstat_OBJS) \
	$(djacob_OBJS) $(dsin_OBJS) $(dmean_OBJS) $(dstddev_OBJS)

dtf_OBJS	=dtf.o
dtf:	$(dtf_OBJS) $(LIBS)
	g++ -o $@ $(dtf_OBJS) $(LIBS) $(SYSLIBS)

d2ts_OBJS	=d2ts.o
d2ts:	$(d2ts_OBJS) $(LIBS)
	g++ -o $@ $(d2ts_OBJS) $(LIBS) $(SYSLIBS)

drand_OBJS	=drand.o
drand:	$(drand_OBJS) $(LIBS)
	g++ -o $@ $(drand_OBJS) $(LIBS) $(SYSLIBS)

dwtest_OBJS	=dwtest.o
dwtest:	$(dwtest_OBJS) $(LIBS)
	g++ -o $@ $(dwtest_OBJS) $(LIBS) $(SYSLIBS)

dwtest2_OBJS	=dwtest2.o
dwtest2:	$(dwtest2_OBJS) $(LIBS)
	g++ -o $@ $(dwtest2_OBJS) $(LIBS) $(SYSLIBS)

dmse_OBJS	=dmse.o
dmse:	$(dmse_OBJS) $(LIBS)
	g++ -o $@ $(dmse_OBJS) $(LIBS) $(SYSLIBS)

dcorr_OBJS	=dcorr.o
dcorr:	$(dcorr_OBJS) $(LIBS)
	g++ -o $@ $(dcorr_OBJS) $(LIBS) $(SYSLIBS)

dsum_OBJS	=dsum.o
dsum:	$(dsum_OBJS) $(LIBS)
	g++ -o $@ $(dsum_OBJS) $(LIBS) $(SYSLIBS)

dstat_OBJS	=dstat.o
dstat:	$(dstat_OBJS) $(LIBS)
	g++ -o $@ $(dstat_OBJS) $(LIBS) $(SYSLIBS)

djacob_OBJS	=djacob.o
djacob:	$(djacob_OBJS) $(LIBS)
	g++ -o $@ $(djacob_OBJS) $(LIBS) $(SYSLIBS)

dsin_OBJS	=dsin.o
dsin:	$(dsin_OBJS) $(LIBS)
	g++ -o $@ $(dsin_OBJS) $(LIBS) $(SYSLIBS)

dmean_OBJS	=dmean.o
dmean:	$(dmean_OBJS) $(LIBS)
	g++ -o $@ $(dmean_OBJS) $(LIBS) $(SYSLIBS)

dstddev_OBJS	=dstddev.o
dstddev:	$(dstddev_OBJS) $(LIBS)
	g++ -o $@ $(dstddev_OBJS) $(LIBS) $(SYSLIBS)

clean:
	-@rm -f $(OBJS) $(PROGRAMS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
