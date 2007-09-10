# CXXFLAGS=$(FLAGS)

LIBSRCS=normaldistr.cpp \
	numintegral.cpp

LIBOBJS=$(LIBSRCS:.cpp=.o)

LIBHDRS=normaldistr.hpp \
	numintegral.hpp

TESTS= test_normaldistr \
	test_numintegral

TESTSRCS=test_normaldistr.cpp \
	test_numintegral.cpp

SOURCES=$(LIBSRCS) $(TESTSRCS)

OBJECTS=$(LIBOBJS) $(TESTSRCS:.cpp=.o)

test_normaldistr: test_normaldistr.o $(LIBOBJS)
	g++ -o $@ test_normaldistr.o $(LIBOBJS) -lm

test_numintegral: $@.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

pdf: pdf.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

cdf: cdf.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

all: $(LIBOBJS) $(TESTS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(LIBOBJS)
