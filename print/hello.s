SYSEXIT = 1        # Numer wywołania systemowego dla zakończenia programu
EXIT_SUCCESS = 0   # Kod sukcesu zwracany przy zakończeniu programu
SYSWRITE = 4       # Numer wywołania systemowego dla pisania do deskryptora pliku
STDOUT = 1         # Deskryptor standardowego wyjścia

.global _start     # Deklaracja symbolu _start jako globalnego (widocznego dla linkera)

.text              # Początek sekcji kodu
msg: .ascii "Hello! \n" # Definiujemy ciąg znaków z wiadomością
msg_len = . - msg  # Obliczamy długość wiadomości (kropka to obecny adres)

_start:            # Punkt startowy programu
    # Operacja pisania do standardowego wyjścia
    mov $SYSWRITE, %eax # Umieszczamy numer wywołania systemowego (4) w rejestrze eax
    mov $STDOUT, %ebx   # Pierwszy argument - deskryptor wyjścia (1) do rejestru ebx
    mov $msg, %ecx      # Drugi argument - adres wiadomości do rejestru ecx
    mov $msg_len, %edx  # Trzeci argument - długość wiadomości do rejestru edx
    int $0x80           # Wywołanie przerwania systemowego (wykonanie syscall)

    # Zakończenie programu
    mov $SYSEXIT, %eax  # Umieszczamy numer wywołania exit (1) w rejestrze eax
    mov $EXIT_SUCCESS, %ebx # Umieszczamy kod sukcesu (0) w rejestrze ebx
    int $0x80           # Wywołanie przerwania systemowego (wykonanie syscall)