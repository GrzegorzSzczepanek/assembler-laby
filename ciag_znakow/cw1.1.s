.data
msg1: .ascii "Podaj tekst: "
msg1_len = . - msg1
msg2: .ascii "Przekształcony tekst: "
msg2_len = . - msg2
buffer: .space 100
buffer_len = . - buffer

.text
.global _start

_start:
    # wyświetl 'podaj tekst'
    mov $4, %eax
    mov $1, %ebx
    mov $msg1, %ecx
    mov $msg1_len, %edx
    int $0x80

    # czytamy stdin
    mov $3, %eax          # setup syscalla na read syscall
    mov $0, %ebx          # file descriptor 0 (standardowe wejscie)
    mov $buffer, %ecx     # adres w ktorym zapisujemy input
    mov $buffer_len, %edx # maksymalna liczba bitow do odczytania
    int $0x80             # wykonujemy syscall
    mov %eax, %esi        # zapisujemy bajty ktore faktycznie odczytalismy

    # Przetwarzanie inputu - zamiana wielkosci liter
    mov $0, %edi          # inicjalizacja licznika pozycji znaku
    mov $buffer, %ebx     # wskaznik na poczatek buffera

# 
process_loop:
    cmp %esi, %edi        # sprawdzamy czy przetworzyliśmy wszystkie znaki
    jge process_done      # jesli tak, konczymy

    movb (%ebx), %cl      # pobieramy aktualny znak
    
    # sprawdzamy czy to litera
    
    # sprawdzamy czy to mala litera (ASCII: 97-122)
    cmp $97, %cl
    jl check_uppercase
    cmp $122, %cl
    jg check_uppercase
    
    # to mala litera, zamieniamy na duza (odejmujemy 32)
    subb $32, %cl
    jmp check_second_letter
    
check_uppercase:
    # sprawdzamy czy to duza litera (ASCII: 65-90)
    cmp $65, %cl
    jl not_letter
    cmp $90, %cl
    jg not_letter
    
    # to duza litera, zamieniamy na mala (dodajemy 32)
    addb $32, %cl
    
check_second_letter:
    # sprawdzamy czy to co druga litera (indeksy 1, 3, 5, itd.)
    mov %edi, %edx
    and $1, %edx          # sprawdzamy czy nieparzysta pozycja
    jz store_and_continue # jesli parzysta, pomijamy druga inwersje
    
    # dla nieparzystych pozycji (1, 3, 5, itd.), odwracamy wielkosc jeszcze raz
    
    # sprawdzamy czy teraz jest mala (ASCII: 97-122)
    cmp $97, %cl
    jl second_check_uppercase
    cmp $122, %cl
    jg second_check_uppercase
    
    # to mala litera, zamieniamy na duza (odejmujemy 32)
    subb $32, %cl
    jmp store_and_continue
    
second_check_uppercase:
    # sprawdzamy czy teraz jest duza (ASCII: 65-90)
    cmp $65, %cl
    jl store_and_continue
    cmp $90, %cl
    jg store_and_continue
    
    # to duza litera, zamieniamy na mala (dodajemy 32)
    addb $32, %cl
    jmp store_and_continue
    
not_letter:
    # brak zmian dla znakow niebedacych literami

store_and_continue:
    movb %cl, (%ebx)      # zapisujemy zmodyfikowany znak z powrotem

    inc %ebx              # przechodzimy do nastepnego znaku
    inc %edi              # zwiekszamy licznik
    jmp process_loop      # kontynuujemy petle

process_done:
    # wyswietl 'przeksztalcony tekst'
    mov $4, %eax
    mov $1, %ebx
    mov $msg2, %ecx
    mov $msg2_len, %edx
    int $0x80

    # wyswietl przetworzony input
    mov $4, %eax
    mov $1, %ebx
    mov $buffer, %ecx
    mov %esi, %edx        # uzywamy liczby bitow ktore odczytalismy
    int $0x80
    
    mov $1, %eax
    mov $0, %ebx
    int $0x80