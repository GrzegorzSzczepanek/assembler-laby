CC = gcc
ASM = as
CFLAGS = -Wall -m64
ASMFLAGS = --64

TARGET = matrix_det
ASM_SRC = determinant.asm
C_SRC = main.c
ASM_OBJ = $(ASM_SRC:.asm=.o)
C_OBJ = $(C_SRC:.c=.o)

all: $(TARGET)

$(TARGET): $(ASM_OBJ) $(C_OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(TARGET) *.o

.PHONY: all clean