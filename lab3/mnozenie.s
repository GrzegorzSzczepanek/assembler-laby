.section .data
    num1: .long 4       
    num2: .long 12      
    msg: .ascii "The result of multiplication is: "
    msg_len = . - msg
    result: .space 16    # buffer na wynik jako string
    newline: .ascii "\n"

.section .text
    .global _start

_start:
        # mnozymy tutaj imulem ktory bierze inta i mnozy 
    movl num1, %eax       # Ładujemy wartość num1 (4) do rejestru %eax
    imull num2, %eax      # Mnożymy wartość w %eax przez num2 (12)
                          # Wynik mnożenia (4 * 12 = 48) jest zapisywany w %eax
                          # Instrukcja imull wykonuje mnożenie ze znakiem (signed multiplication),
                          # ale ponieważ nasze liczby są dodatnie, wynik jest taki sam jak dla unsigned.   # Result stored in %eax
    
    # zamiana liczby na dziesietna
    movl $result, %edi   # Destination buffer
    addl $15, %edi       # zaczynamy od konca buffera
    movb $0, (%edi)      # Null-terminate stringa
    decl %edi
    
    movl $10, %ebx       # dzielnik dla zamiany na system dziesietny
    
convert_loop:
    movl $0, %edx        # wyczysc high bits do dzielenia
    divl %ebx            # podziel przez 10, reszta w edx
    addb $'0', %dl       # zamiana na ascii
    movb %dl, (%edi)     # zachowaj cydre
    decl %edi            # idziewmy wstecz w bufferze
    
    cmpl $0, %eax        # sprawdzenie czy skonczylismy
    jne convert_loop     # dopoki nie zero to kontynuujemy
    
    incl %edi            # wstazujemy na pierwsza cyfre
    
    # printujemy
    movl $4, %eax        # sys_write system call
    movl $1, %ebx        # File descriptor 1 (stdout)
    movl $msg, %ecx      # Message to write
    movl $msg_len, %edx  # Message length
    int $0x80            # Call kernel
    
    # Print the result
    movl $4, %eax        # sys_write system call
    movl $1, %ebx        # File descriptor 1 (stdout)
    movl %edi, %ecx      # Result string
    movl $result, %edx
    addl $15, %edx
    subl %edi, %edx      # Calculate length
    int $0x80            # Call kernel
    
    # Print newline
    movl $4, %eax        # sys_write system call
    movl $1, %ebx        # File descriptor 1 (stdout)
    movl $newline, %ecx  # Newline character
    movl $1, %edx        # Length 1
    int $0x80            # Call kernel
    
    # Exit program
    movl $1, %eax        # sys_exit system call
    xorl %ebx, %ebx      # Return code 0
    int $0x80            # Call kernel