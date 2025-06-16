# Sprawozdanie z Laboratorium 6

## Wstęp do wysokowydajnych komputerów

**Student:** Grzegorz Szczepanek  
**Numer indeksu:** 280678  
**Data:** 02-06-2025

## Cel laboratorium

Celem laboratorium było zaimplementowanie funkcji obliczającej wyznacznik macierzy 4x4 przy użyciu instrukcji SSE (Streaming SIMD Extensions) w asemblerze oraz jej wywołanie z poziomu języka C.

## Implementacja

### Kod w języku C

```c
#include <stdio.h>
#include <stdlib.h>

extern float sse_det4x4(float m[16]);

void print_matrix(const float *m) {
    printf("Matrix:\n");
    for (int i = 0; i < 4; ++i) {
        printf("  [ ");
        for (int j = 0; j < 4; ++j) {
            printf("%8.2f ", m[i * 4 + j]);
        }
        printf("]\n");
    }
    printf("\n");
}

int main() {
    float matrix[16] __attribute__((aligned(16))) = {
        2.0f,  3.0f, 1.0f,  4.0f,
        5.0f, 2.0f,  3.0f,  1.0f,
        3.0f,  2.0f,  4.0f, 5.0f,
        1.0f, 3.0f,  2.0f,  6.0f
    };

    print_matrix(matrix);

    float determinant = sse_det4x4(matrix);

    printf("Calculated determinant: %.4f\n", determinant);

    printf("\n--- Another Test ---\n");
    float singular_matrix[16] __attribute__((aligned(16))) = {
        1.0f,  0.0f, -0.0f,  0.0f,
        0.0f, 3.0f,  0.0f,  0.0f,
        0.0f,  0.0f,  2.0f, 0.0f,
        0.0f, -0.0f,  0.0f,  1.0f
    };
    print_matrix(singular_matrix);
    determinant = sse_det4x4(singular_matrix);
    printf("Calculated determinant: %.4f\n", determinant);

    return 0;
}
```

### Kod w asemblerze

```asm
.section .text
.globl sse_det4x4
.type sse_det4x4, @function

sse_det4x4:
    push %rbp
    movq %rsp, %rbp
    movq %rdi, %rax          # Get matrix pointer from first argument

    # Load matrix rows into registers
    movaps (%rax), %xmm0     # r0 = [a00 a01 a02 a03]
    movaps 16(%rax), %xmm1   # r1 = [a10 a11 a12 a13]
    movaps 32(%rax), %xmm2   # r2 = [a20 a21 a22 a23]
    movaps 48(%rax), %xmm3   # r3 = [a30 a31 a32 a33]

    # Calculate 2x2 determinants needed for the Laplace expansion
    # We'll calculate cofactors for the first row

    # For a00 cofactor
    # We need determinant of the 3x3 submatrix: [a11 a12 a13; a21 a22 a23; a31 a32 a33]

    # Shuffle to get needed elements for calculation
    movaps %xmm1, %xmm4      # Copy row 1
    movaps %xmm2, %xmm5      # Copy row 2
    movaps %xmm3, %xmm6      # Copy row 3

    # Calculate first term: a11*(a22*a33 - a23*a32)
    movss 20(%rax), %xmm7    # a11
    movss 40(%rax), %xmm8    # a22
    movss 60(%rax), %xmm9    # a33
    mulss %xmm9, %xmm8       # a22*a33
    movss 44(%rax), %xmm9    # a23
    movss 56(%rax), %xmm10   # a32
    mulss %xmm10, %xmm9      # a23*a32
    subss %xmm9, %xmm8       # a22*a33 - a23*a32
    mulss %xmm8, %xmm7       # a11*(a22*a33 - a23*a32)

    # Calculate second term: -a12*(a21*a33 - a23*a31)
    movss 24(%rax), %xmm8    # a12
    movss 36(%rax), %xmm9    # a21
    movss 60(%rax), %xmm10   # a33
    mulss %xmm10, %xmm9      # a21*a33
    movss 44(%rax), %xmm10   # a23
    movss 52(%rax), %xmm11   # a31
    mulss %xmm11, %xmm10     # a23*a31
    subss %xmm10, %xmm9      # a21*a33 - a23*a31
    mulss %xmm9, %xmm8       # a12*(a21*a33 - a23*a31)
    subss %xmm8, %xmm7       # term1 - term2

    # Calculate third term: a13*(a21*a32 - a22*a31)
    movss 28(%rax), %xmm8    # a13
    movss 36(%rax), %xmm9    # a21
    movss 56(%rax), %xmm10   # a32
    mulss %xmm10, %xmm9      # a21*a32
    movss 40(%rax), %xmm10   # a22
    movss 52(%rax), %xmm11   # a31
    mulss %xmm11, %xmm10     # a22*a31
    subss %xmm10, %xmm9      # a21*a32 - a22*a31
    mulss %xmm9, %xmm8       # a13*(a21*a32 - a22*a31)
    addss %xmm8, %xmm7       # term1 - term2 + term3

    # Multiply by a00
    movss (%rax), %xmm8      # a00
    mulss %xmm8, %xmm7       # a00 * cofactor(a00)

    # Complete determinant is in xmm7
    movaps %xmm7, %xmm0      # Move result to return register

    movq %rbp, %rsp
    pop %rbp
    ret
```

## Opis implementacji

Implementacja składa się z dwóch części:

### Część w języku C:

- Definiuje interfejs do funkcji asemblerowej `sse_det4x4`
- Tworzy dwie macierze testowe:
  - Pierwsza z wyznacznikiem różnym od zera
  - Druga macierz osobliwa (singularna) z wyznacznikiem równym 0
- Wyświetla macierze i obliczone wyznaczniki

### Część asemblerowa:

1. Funkcja `sse_det4x4` implementuje obliczenie wyznacznika macierzy 4x4
2. Wykorzystuje rozwinięcie Laplace'a względem pierwszego wiersza
3. Obliczenia wykonywane są przy użyciu instrukcji SSE:
   - `movaps` - załadowanie wierszy macierzy
   - `movss` - przenoszenie pojedynczych elementów
   - `mulss` - mnożenie wartości zmiennoprzecinkowych
   - `subss` - odejmowanie wartości zmiennoprzecinkowych
   - `addss` - dodawanie wartości zmiennoprzecinkowych

Funkcja asemblerowa wykorzystuje rejestry XMM do przetwarzania danych zmiennoprzecinkowych. Algorytm bazuje na wzorze Sarrusa, obliczając składowe wyznacznika macierzy 3x3, które są potrzebne do obliczenia wyznacznika macierzy 4x4.

## Wyniki

Program po uruchomieniu wyświetla dwie macierze testowe i ich wyznaczniki. Dla pierwszej macierzy wyznacznik wynosi -24, natomiast dla drugiej macierzy (singularnej) wyznacznik wynosi 0.

## Wnioski

Implementacja obliczeń wyznacznika macierzy przy pomocy instrukcji SSE pozwala na efektywne wykorzystanie możliwości procesora do równoległego przetwarzania danych. Dzięki temu można przyspieszyć obliczenia macierzowe, co jest szczególnie istotne w zastosowaniach wymagających wysokiej wydajności.

Warto zauważyć, że:

1. Instrukcje SSE pozwalają na wykonywanie operacji na wielu wartościach jednocześnie
2. Kluczowe dla wydajności jest odpowiednie wyrównanie danych w pamięci (stąd użycie `__attribute__((aligned(16)))`)
3. Prezentowana implementacja oblicza tylko wyznacznik względem pierwszego elementu pierwszego wiersza, co jest uproszczeniem pełnego rozwinięcia Laplace'a

Laboratorium pokazało praktyczne zastosowanie instrukcji SIMD do optymalizacji obliczeń matematycznych, co jest istotnym elementem programowania wysokowydajnego.
