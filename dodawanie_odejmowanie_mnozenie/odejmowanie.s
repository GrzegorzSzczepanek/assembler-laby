.section .data
	num1:    .long 100        # Pierwsza liczba (ta większa)
	num2:    .long 40         # druga
	result:  .space 12        # buffer na result string
	newline: .byte 10         # nowa linia

.section .text
	.global _start

_start:
	# Perform the subtraction
	movl num1, %eax           # Load first number into eax
	subl num2, %eax           # eax = eax - num2

	# Convert result to string
	movl $result, %esi        # esi points to result buffer
	addl $11, %esi            # Point to end of buffer
	movb $0, (%esi)           # Null-terminate string
	decl %esi                 # Move back one position

	# Check if negative
	cmpl $0, %eax
	jge positive

	# Handle negative number
	negl %eax                 # Make positive for conversion
	movl $1, %edi             # Set negative flag
	jmp convert

positive:
	movl $0, %edi             # Clear negative flag

convert:
	# Handle special case of zero
	cmpl $0, %eax
	jne convert_loop

	movb $'0', (%esi)
	decl %esi
	jmp finalize

convert_loop:
	# Check if done converting
	cmpl $0, %eax
	je finalize

	# Get next digit
	movl $0, %edx             # Clear upper bits before division
	movl $10, %ecx            # Divisor
	divl %ecx                 # eax = edx:eax / ecx, edx = remainder

	# Convert to ASCII and store
	addb $'0', %dl
	movb %dl, (%esi)
	decl %esi

	jmp convert_loop

finalize:
	# Add negative sign if needed
	cmpl $0, %edi
	je prepare_output

	movb $'-', (%esi)
	decl %esi

prepare_output:
	# Point to first character of result
	incl %esi

	# Print the result
	movl $4, %eax             # sys_write system call
	movl $1, %ebx             # STDOUT
	movl %esi, %ecx           # Pointer to result string
	movl $result, %edx
	addl $11, %edx
	subl %esi, %edx           # Length of string
	int $0x80

	# Print newline
	movl $4, %eax
	movl $1, %ebx
	movl $newline, %ecx
	movl $1, %edx
	int $0x80

	# Exit
	movl $1, %eax             # sys_exit
	xorl %ebx, %ebx           # Exit code 0
	int $0x80