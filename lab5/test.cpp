// test.cpp

#include <stdio.h>

extern "C" int dodaj(int a, int b);
extern "C" int testowa();

int main() {
    printf("Hello world\n");
    int result = testowa();
    int suma = dodaj(21, 37);
    printf("Testowa funkcja return: %d\n", result);
    printf("Dodaj funkcja return: %d\n", suma);
    return 0;
}
