# CXXFLAGS=$(FLAGS)

LIBSRCS=normaldistr.cpp

LIBOBJS=$(LIBSRCS:.cpp=.o)

LIBHDRS=normaldistr.hpp

TESTS= test_normaldistr

TESTSRCS=test_normaldistr.cpp

SOURCES=$(LIBSRCS) $(TESTSRCS)

OBJECTS=$(LIBOBJS) $(TESTSRCS:.cpp=.o)

test_normaldistr: test_normaldistr.o $(LIBOBJS)
	g++ -o $@ test_normaldistr.o $(LIBOBJS) -lm

pdf: pdf.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

cdf: cdf.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

erfc: erfc.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

all: $(LIBOBJS) $(TESTS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(LIBOBJS)
