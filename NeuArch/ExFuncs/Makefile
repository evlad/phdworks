PROGRAMS=nosense.so

SYSLIBS	=-lm
LIBS	=../libpnna.a ../../Matrix.041/libmatrix.a

SRCS	=nosense.cpp

OBSJ	=$(nosense_OBJS)

CXXFLAGS=$(FLAGS) -fpic -I../../Matrix.041 -I.. -I.

nosense_OBJS	=nosense.o
nosense.so:	$(nosense_OBJS) $(LIBS)
	g++ -shared -o $@ $(nosense_OBJS) $(LIBS) $(SYSLIBS)

clean:
	rm -f $(PROGRAMS) $(OBJS)

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
