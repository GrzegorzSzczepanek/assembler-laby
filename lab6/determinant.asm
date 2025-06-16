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