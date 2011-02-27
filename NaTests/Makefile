PROGRAMS=PNDely01 \
	 PNBu1201 \
	 PNNNCo01

PNDely01:	PNDely01.o $(LIBS)
	$(CCC) -o $@ $@.o $(LDFLAGS) $(LIBS)

PNBu1201:	PNBu1201.o $(LIBS)
	$(CCC) -o $@ $@.o $(LDFLAGS) $(LIBS)

PNNNCo01:	PNNNCo01.o $(LIBS)
	$(CCC) -o $@ $@.o $(LDFLAGS) $(LIBS)

all:	$(PROGRAMS)

CCC	=g++

CXXFLAGS=$(FLAGS) -I../Matrix.041 -I../NeuArch

LIBS	=../NeuArch/libpnna.a ../Matrix.041/libmatrix.a

tests:	$(PROGRAMS)
	-@for p in $(PROGRAMS) ; do \
	  if [ -x $$p.sh ] ; \
	    then echo ">>> Run $$p.sh" ; ./$${p}.sh ; \
	    else echo ">>> Run $$p" ; \
	      if ./$${p} ; \
	        then echo " => $$p: ok, passed" ; \
	        else echo " => $$p: FAILED ($$?), see $$p.log" ; \
	      fi ; \
	  fi ; \
	done

clean:	clean-tests
	-@rm -f *.o $(PROGRAMS)

clean-tests:
	-@rm -f *.log *.map *.diff

.cpp.o:
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<
