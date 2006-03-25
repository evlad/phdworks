CFLAGS	=$(FLAGS) -fPIC

SRCS	=matcreat.c \
	matdurbn.c \
	matinv.c \
	matsolve.c \
	mattoepz.c \
	matadd.c \
	matdet.c \
	matdump.c \
	materr.c \
	matmul.c \
	matsub.c \
	matsubx.c \
	mattran.c

OBJS	=matcreat.o \
	matdurbn.o \
	matinv.o \
	matsolve.o \
	mattoepz.o \
	matadd.o \
	matdet.o \
	matdump.o \
	materr.o \
	matmul.o \
	matsub.o \
	matsubx.o \
	mattran.o

all:	libmatrix.a

clean:
	-@rm -f $(OBJS)

libmatrix.a:	$(OBJS)
	ar -ruv $@ $(OBJS)
