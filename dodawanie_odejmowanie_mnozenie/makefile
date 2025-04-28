all: dodawanie odejmowanie mnozenie

dodawanie: dodawanie.o
	ld -o dodawanie dodawanie.o

odejmowanie: odejmowanie.o
	ld -o odejmowanie odejmowanie.o

mnozenie: mnozenie.o
	ld -o mnozenie mnozenie.o

%.o: %.s
	as -o $@ $<

clean:
	rm -f *.o dodawanie odejmowanie mnozenie

# .PHONY: all clean