SYSEXIT = 1
EXIT_SUCCESS = 0
SYSWRITE = 4
STDOUT = 1
SYSREAD = 3
STDIN = 0

.global _start

.data
    msg: .ascii "Hello! \n" # difiniujemy message string
    msg_len = . - msg # dlugosc wiadomosci (ktopka to obecny adres)

    msg2: .ascii "Written text: "
    msg2_len = . - msg2

    newline: .ascii "\n"
    newline_len = . - newline

    buffer: .ascii "                    "    # buffer na nasz input (increased size)
    buffer_len = . - buffer

.text
_start:
    # napisanie do stdout i wystwietlamy message
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $msg, %ecx
    mov $msg_len, %edx
    int $0x80

    # czytamy stdin
    mov $SYSREAD, %eax # setup syscalla na read syscall
    mov $STDIN, %ebx # file descriptor 0 (standard input)
    mov $buffer, %ecx # adres w ktorym zapisujemy input
    mov $buffer_len, %edx # maksymalna liczba bitow do odczytania
    int $0x80 # wykonujemy syscall
    mov %eax, %esi  # zapisujemy bajty ktore faktycznie odczytalismy

    # wystlietl 'written text'
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $msg2, %ecx
    mov $msg2_len, %edx
    int $0x80

    # wystlietl input
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $buffer, %ecx
    mov %esi, %edx  # uzywamt liczby bitow ktore odczytalism
    int $0x80
    
    mov $SYSEXIT, %eax
    mov $EXIT_SUCCESS, %ebx
    int $0x80