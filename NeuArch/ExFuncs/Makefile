PROGRAMS=nosense.so \
	saturat.so

SYSLIBS	=-lm
LIBS	=../libpnna.a ../../Matrix.041/libmatrix.a

SRCS	=nosense.cpp \
	saturat.cpp

OBJS	=$(nosense_OBJS) \
	$(saturat_OBJS)

CXXFLAGS=$(FLAGS) -fpic -I../../Matrix.041 -I.. -I.

all:	$(PROGRAMS)

nosense_OBJS	=nosense.o
nosense.so:	$(nosense_OBJS) $(LIBS)
	g++ -shared -o $@ $(nosense_OBJS) $(LIBS) $(SYSLIBS)

saturat_OBJS	=saturat.o
saturat.so:	$(saturat_OBJS) $(LIBS)
	g++ -shared -o $@ $(saturat_OBJS) $(LIBS) $(SYSLIBS)

clean:
	rm -f $(PROGRAMS) $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

###
nosense.o:	nosense.h
saturat.o:	saturat.h
