.data
	matrix: .zero 1600
	matrixCopy: .zero 1600
	columnIndex: .space 4
	lineIndex: .space 4
	left: .space 4
	right: .space 4
	p: .space 4
	k: .space 4
	kEvolutii: .space 4
	index: .space 4
	m: .long 4
	n: .long 5
    m1: .long 4
	n1: .long 5
	i: .space 4
	j: .space 4
	i1: .space 4
	j1: .space 4
	i2: .space 4
	j2: .space 4
	aux: .space 4
	copieEAX: .space 4
	copieEBX: .space 4
	punctCurent: .space 4
	vecini: .space 4
	formatScanf: .asciz "%ld"
	formatPrintf: .asciz "%ld"
	formatStringf: .asciz "%s"
	newLine: .asciz "\n"
	space: .asciz " "
.text
    pr_afisare_matrice:
            decl m
            decl n
            movl $1, lineIndex
            for_lines_1:
                movl lineIndex, %ecx
                cmp m, %ecx
                je et_exit_afis
                movl $1, columnIndex
                for_columns_1:
                    movl columnIndex, %ecx
                    cmp n, %ecx
					et_debug3:
                    je cont_2
                    #eu afisez matrix[lineIndex][columnIndex]
                    movl lineIndex, %eax
                    movl $0, %edx
                    incl n
                    mull n
                    decl n
                    addl columnIndex, %eax
                    movl (%edi, %eax, 4), %ebx
                    pushl %ebx
                    pushl $formatPrintf
                    call printf
                    popl %ebx
                    popl %ebx
					pushl $0
        			call fflush
        			popl %ebx
					movl columnIndex, %ecx
					incl %ecx
					cmp n, %ecx
					je cont_2
					pushl $space
                    pushl $formatStringf
                    call printf
                    popl %ebx
                    popl %ebx
                    incl columnIndex
                    jmp for_columns_1
            cont_2:
            movl $4, %eax
            movl $1, %ebx
            movl $newLine, %ecx
            movl $2, %edx
            int $0x80
            incl lineIndex
            jmp for_lines_1
        et_exit_afis:
            incl m
            incl n
            ret
    
	pr_cum_devine_celula:
		movl %ebx, copieEBX
		movl punctCurent, %eax
		movl $1, %ebx
		cmp %eax, %ebx
		je et_daca_cel_vie
		jne et_daca_cel_moarta
		et_daca_cel_vie:
			movl $2, %eax
			movl vecini, %ebx
			cmp %eax,%ebx
			je et_iesire_devine_celula
			movl $3,%eax
			cmp %eax,%ebx
			je et_iesire_devine_celula
			jmp et_celula_moarte
		
		et_daca_cel_moarta:
			movl $3,%eax
			movl vecini,%ebx
			cmp %eax,%ebx
			je et_celula_inviere
			jmp et_iesire_devine_celula
		
		et_celula_inviere:
			movl $1,punctCurent
            jmp et_iesire_devine_celula
		
		et_celula_moarte:
			movl $0,punctCurent
			jmp et_iesire_devine_celula

		jmp et_iesire_devine_celula
		
		et_iesire_devine_celula:
		movl copieEBX,%ebx
		ret
		
	pr_verificare_vecini:
		movl i,%edx
		movl %edx, i1
		movl j,%edx
		movl %edx, j1
		movl i1,%edx
		movl %edx, i2
		movl j1,%edx
		movl %edx, j2
		decl i1
		decl j1
		incl i2
		incl j2
		movl $0,vecini
		jmp et_for_parcurgere_vecini
		et_for_parcurgere_vecini:
		movl i1, %edx
		movl %edx, lineIndex
		for_lines:
			movl lineIndex, %ecx
			cmp %ecx, i2
			jl et_iesire_for_vecini
			movl j1, %edx
			movl %edx, columnIndex
			for_columns:
				movl columnIndex, %ecx
				cmp %ecx, j2
				jl cont
				xorl %edx, %edx
				movl lineIndex, %eax
				mull n
				addl columnIndex, %eax
				mov %eax, %ecx
				movl (%edi, %ecx, 4), %edx
				addl %edx, vecini
				incl columnIndex
				jmp for_columns
		cont:
			incl lineIndex
			jmp for_lines
		et_iesire_for_vecini:
		decl i2
		decl j2
		movl i2, %eax
		movl $0, %edx
		mull n
		addl j2, %eax
		movl (%edi, %eax, 4),%edx
		subl %edx,vecini
		ret

    

.global main
main:
	pushl $m
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
	pushl $n
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
	pushl $p
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
    incl m
	incl m
	incl n
    incl n
	movl $0, index
	et_for_marcare_celule_vii:
		movl index, %ecx
		cmp %ecx, p
		je et_evolutii
		pushl $left
		pushl $formatScanf
		call scanf
		popl %ebx
		popl %ebx
		incl left
		pushl $right
		pushl $formatScanf
		call scanf
		popl %ebx
		popl %ebx
		incl right
		movl left, %eax
		movl $0, %edx
		mull n
		addl right, %eax
		lea matrix, %edi
		movl $1, (%edi, %eax, 4)
		incl index
		jmp et_for_marcare_celule_vii
    et_evolutii:
    pushl $k
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
	
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

    et_final:
    lea matrix, %edi
	call pr_afisare_matrice
	et_exit:
		pushl $0
        call fflush
        popl %ebx
		movl $1, %eax
		movl $0, %ebx
		int $0x80
