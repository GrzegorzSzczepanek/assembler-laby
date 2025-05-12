// test.cpp

#include <stdio.h>

extern "C" int dodaj(int a, int b);
extern "C" double dodaj2(double a, double b);
extern "C" int testowa();

int main() {
    printf("Hello world\n");
    int result = testowa();
    int suma = dodaj(21, 37);
    double suma_double = dodaj2(21.5, 37.3);
    printf("Testowa funkcja return: %d\n", result);
    printf("Dodaj funkcja return: %d\n", suma);
    printf("Dodaj2 funkcja return: %f\n", suma_double);
    return 0;
}
