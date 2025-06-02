CC = gcc
CFLAGS = -Wall -m32
ASFLAGS = --32

all: matrix_det

matrix_det: matrix_det.o matrix_det_c.o
	$(CC) $(CFLAGS) -o matrix_det matrix_det.o matrix_det_c.o

matrix_det.o: matrix_det.s
	$(CC) $(CFLAGS) -c matrix_det.s -o matrix_det.o

matrix_det_c.o: matrix_det.c
	$(CC) $(CFLAGS) -c matrix_det.c -o matrix_det_c.o

clean:
	rm -f *.o matrix_det