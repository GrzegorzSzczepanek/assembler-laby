all: cw1.1 cw1.2 cw1.5

cw1.1: cw1.1.o
	ld -o cw1.1 cw1.1.o

cw1.2: cw1.2.o
	ld -o cw1.2 cw1.2.o

cw1.5: cw1.5.o
	ld -o cw1.5 cw1.5.o

%.o: %.s
	as -o $@ $<

clean:
	rm -f *.o cw1.1 cw1.2 cw1.5

# .PHONY: all clean