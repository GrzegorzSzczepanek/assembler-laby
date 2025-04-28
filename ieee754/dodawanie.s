.section .data
    double_1: .double 3.5
    double_2: .double 3.14
    double_result: .double 0.0
    msg:    .ascii "The sum is: "
    msgLen  = . - msg
    result: .space 20
    newline: .ascii "\n"

    binary_fmt: .ascii "IEEE 754 Reprezentacja:\n"
                .ascii "Znak: "
    sign_buf:   .space 2
                .ascii " Wykładnik: "
    exp_buf:    .space 12
                .ascii " Mantysa: "
    mant_buf:   .space 53
                .ascii "\n"
    fmt_len = . - binary_fmt

.section .text
.global _start

_start:
    # Add the two doubles using x87 FPU
    fldl double_1       # Load double_1 onto FPU stack
    faddl double_2      # Add double_2 to ST(0)
    fstpl double_result # Store result and pop FPU stack
    
    # Load the result for display
    movq double_result, %rax
    
    # Process sign bit (bit 63)
    movq %rax, %rbx
    shr $63, %rbx
    add $48, %rbx        # Convert to ASCII '0' or '1'
    mov %bl, sign_buf
    mov $32, %bl         # Space
    mov %bl, sign_buf+1
    
    # Process exponent bits (bits 52-62)
    movq %rax, %rbx
    shr $52, %rbx
    and $0x7FF, %rbx     # Mask to get only 11 bits
    
    # Convert exponent bits to ASCII
    mov $10, %rcx        # 11 bits, indices 0-10
    lea exp_buf+10, %rdi # Start from end for easier conversion

exp_loop:
    mov %rbx, %rdx
    and $1, %rdx         # Get least significant bit
    add $48, %dl         # Convert to ASCII
    mov %dl, (%rdi)      # Store in buffer
    shr $1, %rbx         # Shift right for next bit
    dec %rdi             # Move buffer pointer
    dec %rcx
    jns exp_loop
    mov $32, %dl         # Space
    mov %dl, exp_buf+11
    
    # Process mantissa bits (bits 0-51)
    movq %rax, %rbx
    
    # Convert mantissa bits to ASCII
    mov $51, %rcx        # 52 bits, indices 0-51
    lea mant_buf+51, %rdi # Start from end

mant_loop:
    mov %rbx, %rdx
    and $1, %rdx         # Extract least significant bit
    add $48, %dl         # Convert to ASCII
    mov %dl, (%rdi)      # Write to buffer
    shr $1, %rbx         # Shift right for next bit
    dec %rdi             # Move buffer pointer
    dec %rcx
    jns mant_loop
    
    # Print message
    movl $4, %eax
    movl $1, %ebx
    movl $msg, %ecx
    movl $msgLen, %edx
    int $0x80
    
    # Print the sum value (would need additional code for double to string conversion)
    
    # Print newline
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80
    
    # Print binary representation
    movl $4, %eax
    movl $1, %ebx
    movl $binary_fmt, %ecx
    movl $fmt_len, %edx
    int $0x80

    # Exit program
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80