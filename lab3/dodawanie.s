.section .data
	num1:   .long 42          # First hardcoded number
	num2:   .long 58          # Second hardcoded number
	msg:    .ascii "The sum is: "
	msgLen  = . - msg
	result: .space 12         # Buffer to store the result as a string
	newline: .ascii "\n"

.section .text
.globl _start
_start:
	# Load the two numbers and add them
	movl num1, %eax
	addl num2, %eax           # eax now contains the sum
	
	# Convert the result to a string
	movl $0, %esi             # Character counter
	movl $10, %ebx            # Base 10 divisor
	
	# Handle special case if result is 0
	cmpl $0, %eax
	jne convert_loop
	movb $'0', result(%esi)
	incl %esi
	jmp print_result
	
convert_loop:
	cmpl $0, %eax
	je reverse_string
	
	# Divide eax by 10, remainder in edx
	movl $0, %edx
	divl %ebx
	
	# Convert remainder to ASCII and store
	addb $'0', %dl
	movb %dl, result(%esi)
	incl %esi
	jmp convert_loop

reverse_string:
	# Now we need to reverse the string
	movl %esi, %ecx           # Length of the string
	decl %ecx                 # Last valid index
	movl $0, %edi             # Start index
	
reverse_loop:
	cmpl %ecx, %edi
	jge print_result
	
	# Swap characters
	movb result(%edi), %al
	movb result(%ecx), %dl
	movb %dl, result(%edi)
	movb %al, result(%ecx)
	
	incl %edi
	decl %ecx
	jmp reverse_loop

print_result:
	# First print the message
	movl $4, %eax             # sys_write
	movl $1, %ebx             # stdout
	movl $msg, %ecx           # message address
	movl $msgLen, %edx        # message length
	int $0x80
	
	# Then print the result
	movl $4, %eax             # sys_write
	movl $1, %ebx             # stdout
	movl $result, %ecx        # result address
	movl %esi, %edx           # result length
	int $0x80
	
	# Print a newline
	movl $4, %eax             # sys_write
	movl $1, %ebx             # stdout
	movl $newline, %ecx       # newline address
	movl $1, %edx             # length 1
	int $0x80
	
	# Exit the program
	movl $1, %eax             # sys_exit
	movl $0, %ebx             # exit code 0
	int $0x80