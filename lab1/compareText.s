SYSEXIT = 1
EXIT_SUCCESS = 0
SYSWRITE = 4
STDOUT = 1
SYSREAD = 3
STDIN = 0

.global _start

.data
    msg: .ascii "Hello! \n"
    msg_len = . - msg

    msg2: .ascii "Written text: "
    msg2_len = . - msg2

    newline: .ascii "\n"
    newline_len = . - newline

    buffer: .space 255
    buffer_len = 255

    compare_str: .ascii "test\n"
    compare_str_len = . - compare_str

    match_msg: .ascii "Strings match!\n"
    match_msg_len = . - match_msg

    no_match_msg: .ascii "Strings don't match!\n"
    no_match_msg_len = . - no_match_msg

.text
_start:
    # Display prompt
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $msg, %ecx
    mov $msg_len, %edx
    int $0x80

    # Read input
    mov $SYSREAD, %eax
    mov $STDIN, %ebx
    mov $buffer, %ecx
    mov $buffer_len, %edx
    int $0x80
    mov %eax, %esi  # Save actual bytes read

    # Display "Written text:"
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $msg2, %ecx
    mov $msg2_len, %edx
    int $0x80

    # Display the input
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $buffer, %ecx
    mov %esi, %edx
    int $0x80

    # Compare input with compare_str
    mov $0, %edi                  # Initialize counter
        
compare_loop:
    cmp %edi, %esi                # Check if we reached end of input
    je check_compare_len          # If yes, check if compare string also ended
    
    mov $compare_str_len, %ebx
    cmp %edi, %ebx                # Check if we reached end of compare_str
    je strings_no_match           # If yes, but input not done, no match
    
    mov buffer(,%edi,1), %al      # Load character from input into %al
    mov compare_str(,%edi,1), %bl # Load character from compare_str into %bl
    cmp %bl, %al                  # Compare characters
    jne strings_no_match          # If not equal, strings don't match
    
    inc %edi                      # Increment counter
    jmp compare_loop              # Continue loop
    
check_compare_len:
    mov $compare_str_len, %ebx
    cmp %edi, %ebx                # Check if compare_str also ended
    jne strings_no_match          # If not, strings don't match
    
strings_match:
    # Display match message
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $match_msg, %ecx
    mov $match_msg_len, %edx
    int $0x80
    jmp exit
    
strings_no_match:
    # Display no match message
    mov $SYSWRITE, %eax
    mov $STDOUT, %ebx
    mov $no_match_msg, %ecx
    mov $no_match_msg_len, %edx
    int $0x80
    
exit:
    mov $SYSEXIT, %eax
    mov $EXIT_SUCCESS, %ebx
    int $0x80
