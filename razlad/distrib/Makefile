# CXXFLAGS=$(FLAGS)

LIBSRCS=normaldistr.cpp \
	as66.cpp

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

cdf_as66: cdf_as66.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

erfc: erfc.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

erf: erf.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

erf_a: erf_a.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

all: $(LIBOBJS) $(TESTS)

lib: $(LIBOBJS)
	ar ruv libdistrib.a $(LIBOBJS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(LIBOBJS)
