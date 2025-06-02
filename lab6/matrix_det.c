#include <stdio.h>
#include <stdlib.h>

// Deklaracja funkcji assembly
extern float det4x4(float *matrix);

int main() {
    float matrix[16];
    int i;
    
    // Wczytaj macierz 4x4 (wiersz po wierszu)
    printf("Podaj elementy macierzy 4x4 (16 liczb, wiersz po wierszu):\n");
    for (i = 0; i < 16; i++) {
        if (scanf("%f", &matrix[i]) != 1) {
            fprintf(stderr, "Błąd odczytu danych wejściowych!\n");
            return 1;
        }
    }
    
    // Oblicz wyznacznik
    float determinant = det4x4(matrix);
    
    // Wypisz wynik
    printf("Wyznacznik macierzy: %.6f\n", determinant);
    
    return 0;
}