PROGRAMS=nosense.so \
	saturat.so \
	luft.so

SYSLIBS	=-lm
LIBS	=../libpnna.a ../../Matrix.041/libmatrix.a

SRCS	=nosense.cpp \
	saturat.cpp \
	luft.cpp

OBJS	=$(nosense_OBJS) \
	$(saturat_OBJS) \
	$(luft_OBJS)

LINK.so	=g++ -shared
CXXFLAGS=$(FLAGS) -fpic -I../../Matrix.041 -I.. -I.

all:	$(PROGRAMS)

nosense_OBJS	=nosense.o
nosense.so:	$(nosense_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(nosense_OBJS) $(LIBS) $(SYSLIBS)

saturat_OBJS	=saturat.o
saturat.so:	$(saturat_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(saturat_OBJS) $(LIBS) $(SYSLIBS)

luft_OBJS	=luft.o
luft.so:	$(luft_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(luft_OBJS) $(LIBS) $(SYSLIBS)

clean:
	rm -f $(PROGRAMS) $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

###
nosense.o:	nosense.h
saturat.o:	saturat.h
luft.o:	luft.h
