CC = gcc
CFLAGS = -O2 -m64 -msse -mfpmath=sse
LDFLAGS = -lm
TARGET = lab5
SRC = lab5.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) -o $(TARGET) $(SRC) $(CFLAGS) $(LDFLAGS)

clean:
	rm -f $(TARGET)