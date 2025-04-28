.data
msg1: .ascii "Podaj ciag znakow w systemie dziesietnym (0-9): "
msg1_len = . - msg1
msg2: .ascii "Wynik w systemie binarnym: "
msg2_len = . - msg2
buffer: .space 100
buffer_len = . - buffer
result: .space 100
result_len = . - result

.text
.global _start

_start:
    mov $4, %eax
    mov $1, %ebx
    mov $msg1, %ecx
    mov $msg1_len, %edx
    int $0x80

    mov $3, %eax
    mov $0, %ebx
    mov $buffer, %ecx
    mov $buffer_len, %edx
    int $0x80
    
    mov %eax, %esi
    dec %esi

    mov $0, %edi
    mov $buffer, %ebx
    mov $0, %eax

process_loop:
    cmp %esi, %edi
    jge output_binary

    movb (%ebx), %cl
    
    mov %eax, %edx      
    shl $3, %eax        
    shl $1, %edx        
    add %edx, %eax      
    
    cmp $'0', %cl
    jl process_error
    cmp $'9', %cl
    jg process_error
    
    subb $'0', %cl
    add %cl, %al

next_char:
    inc %ebx
    inc %edi
    jmp process_loop

process_error:
    jmp next_char

output_binary:
    mov $result, %ecx
    mov $32, %edx
    add %edx, %ecx
    movb $0, (%ecx)
    dec %ecx

convert_binary_loop:
    movb $'0', (%ecx)
    test $1, %eax
    jz skip_one_bit
    movb $'1', (%ecx)
    
skip_one_bit:
    shr $1, %eax
    dec %ecx
    dec %edx
    jnz convert_binary_loop
    
    inc %ecx
    
    mov $4, %eax
    mov $1, %ebx
    mov $msg2, %ecx
    mov $msg2_len, %edx
    int $0x80
    
    mov $result, %edx
    add $32, %edx
    sub %ecx, %edx
    
    mov $4, %eax
    mov $1, %ebx
    int $0x80
    
    mov $1, %eax
    mov $0, %ebx
    int $0x80
