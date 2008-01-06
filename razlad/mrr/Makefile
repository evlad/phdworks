# CXXFLAGS=$(FLAGS)

LIBSRCS=std_mean.cpp
LIBOBJS=$(LIBSRCS:.cpp=.o)
LIBHDRS=mrr.hpp

TESTS= test_std_mean \
		test_phi_r

TESTSRCS=test_std_mean.cpp \
		test_phi_r.cpp
TESTOBJS=$(TESTSRCS:.cpp=.o)

SOURCES=$(LIBSRCS) $(TESTSRCS)
OBJECTS=$(LIBOBJS) $(TESTOBJS)

CXXFLAGS=-I../distrib -I../integrator
LIBS	=-L../distrib -L../integrator -ldistrib -lintegrator

test_std_mean: $(LIBOBJS) test_std_mean.o
	g++ -o $@ $(LIBOBJS) test_std_mean.o $(LIBS) -lm

test_phi_r: $(LIBOBJS) test_phi_r.o
	g++ -o $@ $(LIBOBJS) test_phi_r.o $(LIBS) -lm

all: $(LIBOBJS) $(TESTS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(OBJECTS)
