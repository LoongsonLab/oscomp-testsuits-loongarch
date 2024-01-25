
SRCS = $(sort $(wildcard *.c))
OBJS = $(SRCS:.c=.o)

CFLAGS = -g -static
LDFLAGS = -static
LIBS = -lpthread -lrt -lpthread


all: clean libc-bench

clean:
	rm -f $(OBJS) libc-bench

test: all
	./libc-bench

libc-bench: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
