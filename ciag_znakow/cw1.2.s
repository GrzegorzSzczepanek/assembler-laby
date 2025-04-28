.data
msg1: .ascii "Podaj ciag znakow w hex (0-9, A-F): "
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
    # wyswietl prosbe o podanie tekstu
    mov $4, %eax
    mov $1, %ebx
    mov $msg1, %ecx
    mov $msg1_len, %edx
    int $0x80

    # czytamy stdin
    mov $3, %eax          # syscall dla read
    mov $0, %ebx          # file descriptor 0 (stdin)
    mov $buffer, %ecx     # adres bufora
    mov $buffer_len, %edx # maksymalna liczba znakow
    int $0x80
    
    mov %eax, %esi        # zapisujemy faktyczna dlugosc wczytanego tekstu
    dec %esi              # pomijamy znak nowej linii

    # przygotowujemy rejestry
    mov $0, %edi          # indeks znaku
    mov $buffer, %ebx     # wskaznik na bufor
    mov $0, %eax          # czyszczenie eax - tu bedziemy trzymac wynik

process_loop:
    cmp %esi, %edi        # sprawdzamy czy przetworzylismy wszystkie znaki
    jge output_binary     # jesli tak, konczymy przetwarzanie

    movb (%ebx), %cl      # pobieramy aktualny znak
    
    # mnozymy aktualny wynik przez 16 (przesuniecie o 4 bity w lewo)
    shl $4, %eax
    
    # sprawdzamy jakiego typu jest znak
    cmp $'0', %cl
    jl process_error      # jesli < '0', blad
    cmp $'9', %cl
    jle digit_0_to_9      # jesli <= '9', to cyfra 0-9
    
    cmp $'A', %cl
    jl process_error      # jesli < 'A', blad
    cmp $'F', %cl
    jle letter_A_to_F     # jesli <= 'F', to litera A-F
    
    cmp $'a', %cl
    jl process_error      # jesli < 'a', blad
    cmp $'f', %cl
    jle letter_a_to_f     # jesli <= 'f', to litera a-f
    
    jmp process_error     # jesli inny znak, blad

digit_0_to_9:
    subb $'0', %cl        # konwertujemy ASCII na wartosc numeryczna
    jmp add_digit

letter_A_to_F:
    subb $'A', %cl        # odejmujemy kod ASCII dla 'A'
    addb $10, %cl         # dodajemy 10, bo 'A' = 10 w hex
    jmp add_digit

letter_a_to_f:
    subb $'a', %cl        # odejmujemy kod ASCII dla 'a'
    addb $10, %cl         # dodajemy 10, bo 'a' = 10 w hex
    
add_digit:
    add %cl, %al          # dodajemy wartosc do wyniku

next_char:
    inc %ebx              # przechodzimy do nastepnego znaku
    inc %edi              # zwiekszamy licznik
    jmp process_loop

process_error:
    # tu mozna dodac obsluge bledu
    jmp next_char

output_binary:
    # eax zawiera teraz liczbe w systemie dziesietnym
    # konwertujemy na reprezentacje binarna
    mov $result, %ecx     # adres bufora wynikowego
    mov $32, %edx         # liczba bitow (dla 32-bitowej liczby)
    add %edx, %ecx        # idziemy na koniec bufora
    movb $0, (%ecx)       # dodajemy null terminator
    dec %ecx              # cofamy sie o jeden znak

convert_binary_loop:
    movb $'0', (%ecx)     # domyslnie wstawiamy '0'
    test $1, %eax         # sprawdzamy najmlodszy bit
    jz skip_one_bit
    movb $'1', (%ecx)     # jesli bit = 1, wstawiamy '1'
    
skip_one_bit:
    shr $1, %eax          # przesuwamy eax w prawo o 1 bit
    dec %ecx              # cofamy wskaznik bufora
    dec %edx              # zmniejszamy licznik bitow
    jnz convert_binary_loop # jesli nie przetworzylismy wszystkich bitow, kontynuujemy
    
    inc %ecx              # przesuwamy wskaznik na pierwszy znaczacy bit
    
    # wyswietl komunikat
    mov $4, %eax
    mov $1, %ebx
    mov $msg2, %ecx
    mov $msg2_len, %edx
    int $0x80
    
    # oblicz dlugosc wyniku binarnego
    mov $result, %edx
    add $32, %edx         # przechodzimy na koniec bufora
    sub %ecx, %edx        # obliczamy dlugosc
    
    # wyswietl wynik binarny
    mov $4, %eax
    mov $1, %ebx
    # ecx juz wskazuje na pierwszy znaczacy bit
    # edx juz zawiera dlugosc
    int $0x80
    
    # koniec programu
    mov $1, %eax
    mov $0, %ebx
    int $0x80