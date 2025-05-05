# test.s — 64-bit AT&T syntax

    # --- Directives ---
    # .globl symbol1, symbol2, ...
    # Makes the specified symbols (labels) visible to the linker.
    # This allows code outside this file (like a C main function) to call these functions.
    .globl  testowa, dodaj

    # .type symbol, @function
    # Informs the linker that the specified symbol represents a function.
    # This helps with debugging and dynamic linking.
    .type   testowa, @function
    .type   dodaj, @function

    # .text
    # Declares that the following lines contain executable code (text segment).
    .text

# --- Function: testowa ---
# A simple function that returns the integer value 42.
testowa:
    # --- Function Prologue ---
    # Standard sequence to set up a stack frame for the function.

    # pushq %rbp
    # Pushes the current value of the Base Pointer register (%rbp) onto the stack.
    # This saves the caller function's base pointer so it can be restored later.
    # 'q' suffix means 'quadword' (64 bits).
    pushq   %rbp

    # movq %rsp, %rbp
    # Moves the current value of the Stack Pointer register (%rsp) into %rbp.
    # This establishes the base pointer for the *current* function's stack frame.
    # Local variables and saved registers will be accessed relative to %rbp.
    movq    %rsp, %rbp

    # --- Function Body ---

    # movl $42, %eax
    # Moves the immediate (literal) value 42 into the lower 32 bits of the %rax register (%eax).
    # By convention (System V AMD64 ABI), the %eax register is used to hold the integer return value of a function.
    # 'l' suffix means 'longword' (32 bits).
    movl    $42, %eax

    # --- Function Epilogue ---
    # Standard sequence to tear down the stack frame and return.

    # popq %rbp
    # Pops the value from the top of the stack into the %rbp register.
    # This restores the caller function's base pointer that was saved at the beginning.
    popq    %rbp

    # ret
    # Returns control to the calling function.
    # It pops the return address (pushed by the 'call' instruction) from the stack
    # and jumps to that address.
    ret

# --- Function: dodaj ---
# A function that adds two integer arguments and returns the sum.
# Arguments are passed via registers according to the System V AMD64 ABI:
# RDI: first argument, RSI: second argument, RDX, RCX, R8, R9 for subsequent args.
# Integer return value goes in EAX.
dodaj:
    # --- Function Prologue ---
    # pushq %rbp
    # Saves the caller's base pointer.
    pushq %rbp # pushes 8 zero bytes to the stack - Note: This comment is incorrect. It pushes the *value* of %rbp.
    # movq %rsp, %rbp
    # Establishes the current function's stack frame base.
    movq %rsp, %rbp # nowa ramka

    # --- Function Body ---

    # movl %edi, %eax
    # Moves the value from the %edi register (lower 32 bits of %rdi, holding the first integer argument 'a')
    # into the %eax register. %eax will hold the result.
    movl    %edi, %eax   # eax = first parameter (a)

    # addl %esi, %eax
    # Adds the value from the %esi register (lower 32 bits of %rsi, holding the second integer argument 'b')
    # to the value currently in %eax. The result is stored back in %eax.
    addl    %esi, %eax   # eax += second parameter (b)

    # --- Function Epilogue ---
    # popq %rbp
    # Restores the caller's base pointer.
    popq %rbp

    # ret
    # Returns control to the caller, with the sum now in %eax.
    ret

# --- Instruction Alternatives ---
# Note: Alternatives might change behavior or performance characteristics.
# pushq %rbp:   subq $8, %rsp; movq %rbp, (%rsp) # Manually adjust stack pointer and store
# movq %rsp, %rbp: No direct single instruction alternative for standard prologue.
# movl $42, %eax: xorl %eax, %eax; addl $42, %eax # Zero out eax, then add 42
# popq %rbp:    movq (%rsp), %rbp; addq $8, %rsp # Manually load and adjust stack pointer
# ret:          popq %rcx; jmp *%rcx             # Manually pop return address and jump
# movl %edi, %eax: leal (%rdi), %eax             # Load Effective Address (often used for moves/simple arithmetic)
# addl %esi, %eax: leal (%rsi, %rdi), %eax       # LEA can perform addition: result = rsi + rdi