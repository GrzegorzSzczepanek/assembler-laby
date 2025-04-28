.section .data
    msg: .ascii "Hello, world\n"
    len = . - msg
    double_1: .double 3.5
    double_2: .double 3.14

    # 

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
    # testowy print
    movl $4, %eax
    movl $1, %ebx
    movl $msg, %ecx
    movl $len, %edx
    int $0x80

    # Laduje wartosc double (8 bajtow)
    movq double_1, %rax
    
    # Obrabiam bit znaku (bit 63)
    movq %rax, %rbx
    shr $63, %rbx
    add $48, %rbx        # Konwersja na ASCII '0' lub '1'
    mov %bl, sign_buf
    mov $32, %bl         # Spacja
    mov %bl, sign_buf+1
    
    # Obrabiam bity wykladnika (bity 52-62)
    movq %rax, %rbx
    shr $52, %rbx
    and $0x7FF, %rbx     # Maska zeby wziac tylko 11 bitow
    
    # Zamieniam bity wykladnika na ASCII
    mov $10, %rcx        # 11 bitow, indeksy 0-10
    lea exp_buf+10, %rdi # Zaczynam od konca bo tak latwiej
exp_loop:
    mov %rbx, %rdx
    and $1, %rdx         # Biore najmniej znaczacy bit
    add $48, %dl         # Konwertuje na ASCII
    mov %dl, (%rdi)      # Wrzucam do bufora
    shr $1, %rbx         # Przesuwam w prawo zeby wziac nastepny bit
    dec %rdi             # Przesuwam wskaznik bufora
    dec %rcx
    jns exp_loop
    mov $32, %dl         # Spacja
    mov %dl, exp_buf+11
    
    # Obrabiam bity mantysy (bity 0-51)
    movq %rax, %rbx
    
    # Konwertuje bity mantysy na ASCII
    mov $51, %rcx        # 52 bity, indeksy 0-51
    lea mant_buf+51, %rdi # Zaczynam od konca
mant_loop:
    mov %rbx, %rdx
    and $1, %rdx         # Wyciagam najmniej znaczacy bit
    add $48, %dl         # Na ASCII
    mov %dl, (%rdi)      # Zapisuje do bufora
    shr $1, %rbx         # Przesuwam w prawo po nastepny bit
    dec %rdi             # Przesuwam wskaznik bufora
    dec %rcx
    jns mant_loop
    
    # Wypisuje reprezentacje binarna
    movl $4, %eax
    movl $1, %ebx
    movl $binary_fmt, %ecx
    movl $fmt_len, %edx
    int $0x80

    # Konczymy program
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80