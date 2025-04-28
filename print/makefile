all: hello writeText compareText
hello: hello.o
	ld -o hello hello.o

writeText: writeText.o
	ld -o writeText writeText.o

compareText: compareText.o
	ld -o compareText compareText.o

hello.o: hello.s
	as -o hello.o hello.s

writeText.o: writeText.s
	as -o writeText.o writeText.s

compareText.o: compareText.s
	as -o compareText.o compareText.s

clean:
	rm -f *.o hello writeText compareText