PROGRAMS=deadzone.so \
	saturat.so \
	luft.so \
	sine.so \
	watertank.so \
	polynomial.so \
	cstr.so

SYSLIBS	=-lm
LIBS	=../libpnna.a ../../Matrix.041/libmatrix.a

SRCS	=deadzone.cpp \
	saturat.cpp \
	luft.cpp \
	sine.cpp \
	watertank.cpp \
	polynomial.cpp \
	cstr.cpp

OBJS	=$(deadzone_OBJS) \
	$(saturat_OBJS) \
	$(luft_OBJS) \
	$(sine_OBJS) \
	$(watertank_OBJS) \
	$(polynomial_OBJS) \
	$(cstr_OBJS)

LINK.so	=g++ -shared
CXXFLAGS=$(FLAGS) -fPIC -I../../Matrix.041 -I.. -I.

all:	$(PROGRAMS)

deadzone_OBJS	=deadzone.o
deadzone.so:	$(deadzone_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(deadzone_OBJS) $(LIBS) $(SYSLIBS)

saturat_OBJS	=saturat.o
saturat.so:	$(saturat_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(saturat_OBJS) $(LIBS) $(SYSLIBS)

luft_OBJS	=luft.o
luft.so:	$(luft_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(luft_OBJS) $(LIBS) $(SYSLIBS)

sine_OBJS	=sine.o
sine.so:	$(sine_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(sine_OBJS) $(LIBS) $(SYSLIBS)

watertank_OBJS	=watertank.o
watertank.so:	$(watertank_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(watertank_OBJS) $(LIBS) $(SYSLIBS)

polynomial_OBJS	=polynomial.o
polynomial.so:	$(polynomial_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(polynomial_OBJS) $(LIBS) $(SYSLIBS)

cstr_OBJS	=cstr.o
cstr.so:	$(cstr_OBJS) $(LIBS)
	$(LINK.so) -o $@ $(cstr_OBJS) $(LIBS) $(SYSLIBS)

clean:
	rm -f $(PROGRAMS) $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

###
deadzone.o:	deadzone.h
saturat.o:	saturat.h
luft.o:	luft.h
sine.o:	sine.h
watertank.o:	watertank.h
polynomial.o:	polynomial.h
cstr.o:	cstr.h
