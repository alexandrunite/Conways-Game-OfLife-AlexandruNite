.section .data
    matrix: .zero 1600            # Matrix for Game of Life (max size 40x40)
    matrixCopy: .zero 1600        # Copy of the matrix for updating
    m: .long 0                    # Number of rows
    n: .long 0                    # Number of columns
    p: .long 0                    # Number of live cells
    k: .long 0                    # Number of generations
    o: .long 0                    # Operation (0 for encrypt, 1 for decrypt)
    message: .space 20            # Message buffer (max 10 characters + null terminator)
    msgLength: .long 0            # Length of the message
    formatInt: .asciz "%d"
    formatHex: .asciz "%x"
    formatStr: .asciz "%s"
    formatMsg: .asciz "0x%s"
    newline: .asciz "\n"

.section .bss

.section .text
    .global main
main:
    # Read m (number of rows)
    push $m
    push $formatInt
    call scanf
    add $8, %esp

    # Read n (number of columns)
    push $n
    push $formatInt
    call scanf
    add $8, %esp

    # Read p (number of live cells)
    push $p
    push $formatInt
    call scanf
    add $8, %esp

    # Initialize the matrix to zeros
    movl m, %eax
    imull n, %eax
    movl %eax, %ecx            # ecx = total number of cells
    movl $0, %edi
    lea matrix, %esi
    cld
    rep stosl

    # Read positions of live cells
    movl p, %ecx               # ecx = p (number of live cells)
read_live_cells:
    cmp $0, %ecx
    je read_k                  # If no more live cells, proceed
    # Read row index
    push %ecx
    subl $4, %esp
    movl %esp, %ebx
    push %ebx
    push $formatInt
    call scanf
    add $8, %esp
    movl (%esp), %edx          # edx = row index
    add $4, %esp
    # Read column index
    subl $4, %esp
    movl %esp, %ebx
    push %ebx
    push $formatInt
    call scanf
    add $8, %esp
    movl (%esp), %eax          # eax = column index
    add $4, %esp
    # Calculate position in matrix
    movl n, %ebx
    imull %edx, %ebx           # ebx = n * row index
    addl %eax, %ebx            # ebx = n * row + col
    movl $1, (%esi, %ebx, 4)   # Set cell to live (1)
    pop %ecx
    decl %ecx
    jmp read_live_cells

read_k:
    # Read k (number of generations)
    push $k
    push $formatInt
    call scanf
    add $8, %esp

    # Read o (operation: 0 for encrypt, 1 for decrypt)
    push $o
    push $formatInt
    call scanf
    add $8, %esp

    # Read message
    lea message, %eax
    push %eax
    push $formatStr
    call scanf
    add $8, %esp

    # Calculate message length
    lea message, %eax
    call strlen
    movl %eax, msgLength

    # Simulate k generations of the Game of Life
    movl k, %ecx               # ecx = k
simulate_generations:
    cmp $0, %ecx
    je generate_key
    # Copy current matrix to matrixCopy
    movl m, %eax
    imull n, %eax
    movl %eax, %edx            # edx = total number of cells
    lea matrix, %esi
    lea matrixCopy, %edi
    movl %edx, %ecx
    cld
    rep movsl
    # Update matrix for next generation
    push m
    push n
    call update_matrix
    add $8, %esp
    decl %ecx
    jmp simulate_generations

generate_key:
    # Generate key from final matrix
    # For simplicity, we'll generate a key of length equal to message length
    # by summing the live cells in each row modulo 256
    lea matrix, %esi
    movl $0, %edi              # edi = key index
    movl m, %ebx               # ebx = m
    movl n, %edx               # edx = n
    movl $0, %ecx              # ecx = row index
generate_key_loop:
    cmp %ecx, msgLength
    jge perform_operation
    movl $0, %eax              # eax = sum of live cells in this row
    movl $0, %esi
    movl n, %edx
sum_row:
    cmp $0, %edx
    je store_key_byte
    movl (%esi), %ebx
    addl %ebx, %eax
    addl $4, %esi
    decl %edx
    jmp sum_row
store_key_byte:
    movb %al, key(%edi)
    incl %edi
    incl %ecx
    jmp generate_key_loop

perform_operation:
    # Encrypt or decrypt the message using the key
    movl msgLength, %ecx
    movl $0, %esi              # esi = message index
    movl $0, %edi              # edi = key index
    movl o, %edx               # edx = operation (0 or 1)
    cmp $0, %edx
    je encrypt_message
    jne decrypt_message

encrypt_message:
    lea message, %ebx
encrypt_loop:
    cmp %ecx, %esi
    je output_result
    movzbl (%ebx, %esi), %al   # Load message byte
    movzbl key(%edi), %bl      # Load key byte
    xorb %bl, %al              # Encrypt byte
    movb %al, (%ebx, %esi)
    incl %esi
    incl %edi
    jmp encrypt_loop

decrypt_message:
    # Convert hex string to bytes
    lea message, %eax
    add $2, %eax               # Skip "0x"
    movl $0, %esi
    movl $0, %edi
convert_hex_to_bytes:
    cmp %esi, msgLength
    je decrypt_loop
    movzbl (%eax, %esi), %al
    call hex_char_to_value
    shl $4, %al
    movzbl (%eax, %esi+1), %bl
    call hex_char_to_value
    or %bl, %al
    movb %al, message(%edi)
    add $2, %esi
    incl %edi
    jmp convert_hex_to_bytes

decrypt_loop:
    cmp %edi, %ecx
    je output_result
    movzbl message(%edi), %al  # Load encrypted byte
    movzbl key(%edi), %bl      # Load key byte
    xorb %bl, %al              # Decrypt byte
    movb %al, message(%edi)
    incl %edi
    jmp decrypt_loop

output_result:
    # Output the result
    lea message, %eax
    push %eax
    push $formatStr
    call printf
    add $8, %esp

    # Exit the program
    movl $0, %ebx
    movl $1, %eax
    int $0x80

# Function to update the matrix for the next generation
# Parameters: m (rows), n (columns)
.type update_matrix, @function
update_matrix:
    push %ebp
    movl %esp, %ebp
    push %esi
    push %edi
    push %ebx
    movl $0, kEvolutii

	et_for_kEvolutii:
		movl kEvolutii, %ecx
		cmp %ecx, k
		je et_final
		movl m,%eax
		mull n
		movl %eax,%ecx
		#de ce am facut chestia de mai sus???
        
		
		mov $0,%eax
		#aici se copiaza matricea in alta matrice
		movl m,%eax
		mull n
		movl %eax,%ecx
		xorl %eax,%eax
		lea matrix, %esi
		lea matrixCopy, %edi
		et_copy_matrix:
			cmp %ecx,%eax
			jge end_copy
			movl (%esi, %eax, 4), %edx
			movl %edx, (%edi, %eax, 4)
			incl %eax
			jmp et_copy_matrix
        end_copy:
        #pana aici este la fel de frumos ca in perioada Craciunului

        lea matrix, %edi
        lea matrixCopy, %esi
		#oare merge et_copy_matrix? we shall find out soon
		#update: merge :D
        movl m,%edx
        movl %edx, m1
        movl n,%edx
        movl %edx, n1
        decl m1
        decl n1
		et_loop_verificare_vecini_fiecare_celula:
			movl $1, i
			for_lines_i:
				movl i, %ecx
				cmp %ecx, m1
				je et_continuare_in_kevolutii
				movl $1, j
				for_columns_j:
					movl j, %ecx
					cmp %ecx, n1
                    #pana aici iar totul e oki
                    et_debug:
					je continuare
					#am folosit o procedura ca sa aflu numarul vecinilor
					movl $0, vecini
					call pr_verificare_vecini
					movl i, %eax
					movl $0, %edx
					mull n
					addl j, %eax
					movl (%edi, %eax, 4), %edx
                    movl %eax, copieEAX
					movl %edx, punctCurent
					call pr_cum_devine_celula
					movl punctCurent, %edx
                    movl copieEAX, %eax
					movl %edx, (%esi, %eax, 4)
					incl j
					jmp for_columns_j
			continuare:
				incl i
				jmp for_lines_i
				
		et_continuare_in_kevolutii:
			xorl %eax, %eax
			#aici se copiaza matricea noua in aia veche, pt a 2-a oara
			movl m, %eax
			mull n
			movl %eax, %ecx
			xorl %eax, %eax
			lea matrix, %esi
			lea matrixCopy, %edi
			et_copy_matrix2:
				cmpl %ecx, %eax
				jge end_copy_2
				movl (%edi, %eax, 4), %edx
				movl %edx, (%esi, %eax, 4)
				incl %eax
				jmp et_copy_matrix2
			end_copy_2:
			incl kEvolutii
			jmp et_for_kEvolutii

    pop %ebx
    pop %edi
    pop %esi
    pop %ebp
    ret

# Function to convert hex character to value
# Input: %al contains the character
# Output: %al contains the value
.type hex_char_to_value, @function
hex_char_to_value:
    cmp $'0', %al
    jl invalid_hex
    cmp $'9', %al
    jle is_digit
    cmp $'A', %al
    jl invalid_hex
    cmp $'F', %al
    jle is_upper
    cmp $'a', %al
    jl invalid_hex
    cmp $'f', %al
    jle is_lower
    jmp invalid_hex
is_digit:
    sub $'0', %al
    ret
is_upper:
    sub $'A', %al
    add $10, %al
    ret
is_lower:
    sub $'a', %al
    add $10, %al
    ret
invalid_hex:
    movl $-1, %eax
    ret
