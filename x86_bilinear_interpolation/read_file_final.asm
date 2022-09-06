; Read txt file and save into text array

STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0



section .data
        filename    db  "imagen.txt",0

        msg1        db "Contenido del archivo:",10,0
        msg2        db "Contenido de la matriz resultante:",10,0

        arraySize   db  4

        new_line    db "",10

        


section .bss
        text    resb    100

        digitSpace resb 100
	    digitSpacePos resb 8

        array   resb 100    


section .text
        global _start

_start:

        ; Se abre el archivo

        mov rax,    SYS_OPEN    ; Abre el archivo
        mov rdi,    filename    ; Nombre del archivo
        mov rsi,    O_RDONLY    ; Modo lectura
        syscall

        ; Se lee el archivo

        push    rax

        mov rdi, rax
        mov rax, SYS_READ       ; Lee el archivo

        mov rsi, text
        mov rdx, 15             ; size_t
        syscall

        mov rax, msg1
        call _print

        mov rax, text
        call _print

        mov rax, new_line
        call _print

        mov rax, new_line
        call _print



_inicio:

        mov r9, 100 ; Multiplicador

        mov r11, 0      ; Num


        mov r12, array  ; Puntero array
        mov rbx, text   ; Puntero txt

        mov r15, 0xff   ; Mascara



_convert_ascii_dec:

        mov rcx, [rbx]  ; Guarda en rcx el valor del txt en la posicion del puntero rbx
        inc rbx         ; Se mueve el puntero de txt

        and rcx, r15    ; Mascara obtener unicamente el primer caracter del registro

        sub rcx, 48     ; Se resta 48 para convertir de char a int

        mov r10, -16    ; Hex de espacio
        cmp rcx, r10    ; Si encuentra un espacio
        je _espacio

        mov r10, -48    ; Hex de fin
        cmp rcx, r10    ; Si encuentra un espacio
        je _espacio


_mult:
        
        mov rax, r9     ; Se mueve el valor actual del multiplicador (100, 10, 1) a rax
        mul rcx         ; Se realiza la multiplicacion rax*rcx y se guarda en rax

        add r11, rax    ; Se aumenta el valor actual del numero guardado en r11

_div:
        mov rdx, 0      ; 0 utilizado en la division para evitar error
        mov rax, r9     ; Se mueve el multiplicador a rax para dividirlo entre 10
        mov r10, 10     ; Se mueve 10 al temporal para dividir el multiplador entre 10
        div r10         ; r9 / 10      o      (100/10)   (10/10)
        mov r9, rax     ; Se actualiza el valor de r9
        
        add r14, 1      ; Se aumenta el contador
        jmp _convert_ascii_dec


_espacio:

        ; rcx tiene el valor 

        mov [r12], r11  ; Guarda en rdx array el valor de rdx en la posicion del puntero r12
        inc r12         ; Se mueve el puntero array

        mov r9, 100
        mov r11, 0


        mov r10, -48    ; Hex de fin
        cmp rcx, r10    ; Si encuentra el fin
        je _end

        jmp _convert_ascii_dec


;input: rax as pointer to string
;output: print string at rax
_print:

        push rax
        mov rbx, 0

_printLoop:
        inc rax
        inc rbx
        mov cl, [rax]
        cmp cl, 0
        jne _printLoop

        mov rax, 1
        mov rdi, STDOUT
        pop rsi
        mov rdx, rbx
        syscall

        ret



; inputs:   rax=array

_printNums:

    mov r8, arraySize       ; IMPORTANTE: VALOR DE N
    mov r9, 0
    mov r10, rax
    mov r15, 0xff   ; Mascara

_printNumsLoop:

    cmp r9, r8
    je  _printNumsEnd

    mov rax, [r10]
    and rax, r15

_prueba:

    call _printRAX

    inc r10

    add r9,1

_printNumsEnd:

    ret 


_printRAX:
	mov rcx, digitSpace
	mov rbx, 10
	mov [rcx], rbx
	inc rcx
	mov [digitSpacePos], rcx

_printRAXLoop:
	mov rdx, 0
	mov rbx, 10
	div rbx
	push rax
	add rdx, 48

	mov rcx, [digitSpacePos]
	mov [rcx], dl
	inc rcx
	mov [digitSpacePos], rcx
	
	pop rax
	cmp rax, 0
	jne _printRAXLoop

_printRAXLoop2:
	mov rcx, [digitSpacePos]

	mov rax, 1
	mov rdi, 1
	mov rsi, rcx
	mov rdx, 1
	syscall

	mov rcx, [digitSpacePos]
	dec rcx
	mov [digitSpacePos], rcx

	cmp rcx, digitSpace
	jge _printRAXLoop2

	ret

_end:

        ; Imprime el contenido del array

        mov rax, msg2
        call _print

        mov rax, array
        call _printNums

        ; Cierra el archivo

        mov rax, 3
        pop rdi
        syscall

        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall


