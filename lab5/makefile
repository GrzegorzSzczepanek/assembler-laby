# Makefile

CXX      := g++
AS       := as
CXXFLAGS := -Wall -g
LDFLAGS  :=

TARGET    := test
CPP_SRC   := test.cpp
ASM_SRC   := test.s

CPP_OBJ := $(CPP_SRC:.cpp=_cpp.o)
ASM_OBJ := $(ASM_SRC:.s=_asm.o)

all: $(TARGET)

$(TARGET): $(CPP_OBJ) $(ASM_OBJ)
	$(CXX) $(LDFLAGS) $^ -o $@

%_cpp.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%_asm.o: %.s
	$(AS) $< -o $@

clean:
	rm -f $(TARGET) $(CPP_OBJ) $(ASM_OBJ)

.PHONY: all clean
