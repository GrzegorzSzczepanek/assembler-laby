.data
.align 16
sh_1020: .long 0x00000001, 0x00000000, 0x00000002, 0x00000000
sh_2301: .long 0x00000002, 0x00000003, 0x00000000, 0x00000001
sh_0112: .long 0x00000000, 0x00000001, 0x00000001, 0x00000002
sh_3233: .long 0x00000003, 0x00000002, 0x00000003, 0x00000003
sh_3210: .long 0x00000003, 0x00000002, 0x00000001, 0x00000000
sh_3232: .long 0x00000003, 0x00000002, 0x00000003, 0x00000002
sh_1313: .long 0x00000001, 0x00000003, 0x00000001, 0x00000003


.text
.globl det4x4
.type det4x4, @function

# Makro obliczające wyrażenie wektorowe A'B'-A"B"
# %1 - wektor A
# %2 - wektor B
# %3 - stała dla shufps (wektor A' i B")
# %4 - stała dla shufps (wektor B' i A")
# %5, %6 - rejestry robocze
# %7 - rejestr wynikowy
.macro calc src1, src2, shuf1, shuf2, tmp1, tmp2, result
    movaps \src1, \result
    movaps \src2, \tmp2
    
    shufps $\shuf1, \result, \result   # A'
    shufps $\shuf2, \tmp2, \tmp2       # B'
    mulps \tmp2, \result               # result := A'B'
    
    movaps \src1, \tmp1
    movaps \src2, \tmp2
    
    shufps $\shuf2, \tmp1, \tmp1       # A"
    shufps $\shuf1, \tmp2, \tmp2       # B"
    mulps \tmp1, \tmp2                 # tmp2 := A"B"
    
    subps \tmp2, \result               # result := A'B' - A"B"
.endm

det4x4:
    pushl %ebp
    movl %esp, %ebp
    
    # Pierwszy argument - wskaźnik do macierzy
    movl 8(%ebp), %esi
    
    # Załaduj wiersze macierzy (A, B, C, D)
    movups (%esi), %xmm0      # A: a0 a1 a2 a3
    movups 16(%esi), %xmm1    # B: b0 b1 b2 b3
    movups 32(%esi), %xmm2    # C: c0 c1 c2 c3
    movups 48(%esi), %xmm3    # D: d0 d1 d2 d3
    
    # xmm4 = wektor I (a0*b1-a1*b0, a2*b0-a0*b2, a0*b3-a3*b0, a1*b2-a2*b1)
    calc %xmm0, %xmm1, 0x99, 0xE1, %xmm6, %xmm7, %xmm4
    
    # xmm5 = wektor II (c2*d3-c3*d2, c1*d3-c3*d1, c1*d2-c2*d1, c0*d3-c3*d0)
    calc %xmm2, %xmm3, 0x4E, 0x9C, %xmm6, %xmm7, %xmm5
    
    # xmm4 *= xmm5 (wektor I * wektor II)
    mulps %xmm5, %xmm4
    
    # Wektor III
    movaps %xmm0, %xmm6       # A
    movaps %xmm1, %xmm7       # B
    
    # Przygotuj wektor [a2, a3, a1, a3]
    shufps $0x9E, %xmm6, %xmm6
    
    # Przygotuj wektor [b3, b1, b3, b1]
    shufps $0x5D, %xmm7, %xmm7
    
    # xmm0 = wektor III (a2*b3-a3*b2, a3*b1-a1*b3, -, -)
    calc %xmm6, %xmm7, 0x88, 0x88, %xmm0, %xmm1, %xmm0
    
    # Wektor IV
    movaps %xmm2, %xmm6       # C
    movaps %xmm3, %xmm7       # D
    
    # Przygotuj wektor [c0, c0, c0, c0]
    shufps $0x00, %xmm6, %xmm6
    
    # Przygotuj wektor [d1, d2, d0, d0]
    shufps $0x59, %xmm7, %xmm7
    
    # xmm1 = wektor IV (c0*d1-c1*d0, c0*d2-c2*d0, -, -)
    calc %xmm6, %xmm7, 0x88, 0x88, %xmm2, %xmm3, %xmm1
    
    # xmm0 *= xmm1 (wektor III * wektor IV)
    mulps %xmm1, %xmm0
    
    # Sumuj wszystkie elementy wektora xmm4
    movaps %xmm4, %xmm1
    shufps $0x4E, %xmm1, %xmm1   # Zamień górną i dolną połowę
    addps %xmm1, %xmm4           # xmm4 = [e0+e2, e1+e3, e2+e0, e3+e1]
    
    movaps %xmm4, %xmm1
    shufps $0xB1, %xmm1, %xmm1   # Zamień sąsiadujące elementy
    addps %xmm1, %xmm4           # xmm4 = [e0+e2+e1+e3, e1+e3+e0+e2, ...]
    
    # Sumuj elementy wektora xmm0
    movaps %xmm0, %xmm1
    shufps $0xB1, %xmm1, %xmm1   # Zamień sąsiadujące elementy
    addps %xmm1, %xmm0           # xmm0 = [f0+f1, f1+f0, ...]
    
    # Dodaj sumy z obu wektorów
    addss %xmm0, %xmm4           # Dodaj tylko pierwsze elementy
    
    # Przenieś wynik do eax poprzez stos
    sub $4, %esp
    movss %xmm4, (%esp)
    flds (%esp)
    add $4, %esp
    
    leave
    ret