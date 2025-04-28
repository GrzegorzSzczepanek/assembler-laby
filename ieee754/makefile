all: ieee dodawanie

ieee: ieee.o
	ld -o ieee ieee.o

dodawanie: dodawanie.o
	ld -o dodawanie dodawanie.o

# mnozenie: mnozenie.o
# 	ld -o mnozenie mnozenie.o

%.o: %.s
	as -o $@ $<

clean:
	rm -f *.o ieee dodawanie # mnozenie

# .PHONY: all clean