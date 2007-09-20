# CXXFLAGS=$(FLAGS)

LIBSRCS=numintegral.cpp

LIBOBJS=$(LIBSRCS:.cpp=.o)

LIBHDRS=numintegral.hpp

TESTS= test_numintegral

TESTSRCS=test_numintegral.cpp

SOURCES=$(LIBSRCS) $(TESTSRCS)

OBJECTS=$(LIBOBJS) $(TESTSRCS:.cpp=.o)

test_numintegral: $@.o $(LIBOBJS)
	g++ -o $@ $@.o $(LIBOBJS) -lm

all: $(LIBOBJS) $(TESTS)

$(OBJECTS):

clean:
	-rm -f $(TESTS) $(LIBOBJS)
