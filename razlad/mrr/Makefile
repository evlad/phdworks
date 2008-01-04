# CXXFLAGS=$(FLAGS)

LIBSRCS=std_mean.cpp
LIBOBJS=$(LIBSRCS:.cpp=.o)
LIBHDRS=mrr.hpp

TESTS= test_std_mean

TESTSRCS=test_std_mean.cpp
TESTOBJS=$(TESTSRCS:.cpp=.o)

SOURCES=$(LIBSRCS) $(TESTSRCS)
OBJECTS=$(LIBOBJS) $(TESTOBJS)

CXXFLAGS=-I../distrib -I../integrator
LIBS	=-L../distrib -L../integrator -ldistrib -lintegrator

test_std_mean: $(OBJECTS)
	g++ -o $@ $(OBJECTS) $(LIBS) -lm

all: $(LIBOBJS) $(TESTS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(LIBOBJS)
