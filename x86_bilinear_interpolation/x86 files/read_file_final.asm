; Read txt file and save into text array

STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

section .data
        filename        db  "imagen.txt",0

        msg1            db  "Contenido del archivo:",0
        msg2            db  "Contenido de la matriz resultante:",0

        new_line        db "",  10          ; Valor de una nueva linea para imprimir

        ; ------------------- CONSTANTES -----------------------------------------
        
        %assign FILE_SIZE   15
        %assign MASK        0xff
        %assign ARRAY_SIZE  4
        %assign ASCII_SPACE -16
        %assign ASCII_END   -48

section .bss
        text            resb    100         ; Contenido del texto leido del archivo

        digitSpace      resb    100         ; Variables usadas para leer numeros enteros
	    digitSpacePos   resb    8

        array           resb    100         ; Arreglo de elementos de la imagen

section .text
        global _start

_start:

        ; [SYSCALL: OPEN]   |   Se abre el archivo

        mov rax, SYS_OPEN    ; %rax          : 0x02                  |   Abre el archivo
        mov rdi, filename    ; arg0 (%rdi)   : const char *filename  |   Nombre del archivo
        mov rsi, O_RDONLY    ; arg2 (%rdx)   : umode_t mode          |   Modo lectura
        syscall

        ; [SYSCALL: READ]   |   Se abre el archivoSe lee el archivo

        push rax                ; Pone en el stack fd para cerrar el archivo al final

        mov rdi, rax            ; arg0 (%rdi)   : unsigned int fd   |   Identificador del archivo abierto
        mov rax, SYS_READ       ; %rax          : 0x00              |   Lee el archivo
        mov rsi, text           ; arg1 (%rsi)   : char *buf         |   Buffer donde se guardara el contenido del archivo
        mov rdx, FILE_SIZE       ; arg2 (%rdx)   : size_t            |   Cantidad de caracteres que se van a leer
        syscall

        ; [SYSCALL: CLOSE]   |   Se cierra el archivo

        mov rax, SYS_CLOSE      ; %rax          : 0x00              |   Lee el archivo
        pop rdi                 ; arg0 (%rdi)   : unsigned int fd   |   Archivo a cerrar
        syscall

        ; Imprime el texto que se ha leido

        mov rax, msg1
        call _print

        mov rax, text
        call _print

;   Convierte el contenido del archivo txt de formato ascii a un arreglo de enteros
_convert_ascii_dec:

        mov r12, array  ; Puntero array
        mov rbx, text   ; Puntero txt

        mov r9, 100     ; Multiplicador

        mov r11, 0      ; Num


_convert_ascii_dec_loop:

        ; Extraccion del caracter correspondiente a cada numero

        mov rcx, [rbx]          ; Guarda en rcx el valor del txt en la posicion del puntero rbx
        inc rbx                 ; Se mueve el puntero de txt

        and rcx, MASK           ; Mascara obtener unicamente el primer caracter del registro

        sub rcx, 48             ; Se resta 48 para convertir de char a int

        cmp rcx, ASCII_SPACE    ; Si encuentra un espacio
        je _space

        cmp rcx, ASCII_END      ; Si encuentra un espacio
        je _space

        ; Multiplicacion para la magnitud
        
        mov rax, r9     ; Se mueve el valor actual del multiplicador (100, 10, 1) a rax
        mul rcx         ; Se realiza la multiplicacion rax*rcx y se guarda en rax

        add r11, rax    ; Se aumenta el valor actual del numero guardado en r11

        ; Se divide el multiplicador para la magnitud de la siguiente iteracion

        mov rdx, 0      ; 0 utilizado en la division para evitar error
        mov rax, r9     ; Se mueve el multiplicador a rax para dividirlo entre 10
        mov r10, 10     ; Se mueve 10 al temporal para dividir el multiplador entre 10
        div r10         ; r9 / 10      o      (100/10)   (10/10)
        mov r9, rax     ; Se actualiza el valor de r9
        
        add r14, 1      ; Se aumenta el contador
        jmp _convert_ascii_dec_loop


_space:

        mov [r12], r11      ; Guarda en la posicion r12 del array el valor de r11
        inc r12             ; Se mueve el puntero del array

        mov r9, 100         ; Resetea el multiplicador
        mov r11, 0          ; Resetea el numero actual

        cmp rcx, ASCII_END  ; Si encuentra el fin
        je _end

        jmp _convert_ascii_dec_loop

;   Imprime el string al que apunta el registro rax
;   input:  rax: puntero al string
;   output: string al que apunta rax
_print:
        push rax
        mov rbx, 0

_printLoop:
        inc rax
        inc rbx
        mov cl, [rax]
        cmp cl, 0
        jne _printLoop

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        pop rsi             ; Se imprime el contenido de rsi
        mov rdx, rbx
        syscall

        call _print_new_line
        call _print_new_line

        ret

_print_new_line:

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, new_line   ; Se imprime un salto de linea
        mov rdx, 1          ; Size
        syscall

        ret

; inputs:   rax=array
_printNums:

        mov r9, 0           ; Contador
        mov r10, rax        ; Puntero de array

_printNumsLoop:

        cmp r9, ARRAY_SIZE  ; Si contador == ARRAY_SIZE
        je  _printNumsEnd

        mov rax, [r10]
        and rax, MASK

        call _printRAX

        inc r10

        add r9,1

        jmp _printNumsLoop

_printNumsEnd:

        call _print_new_line
        call _print_new_line

        ret 

_printRAX:
        mov rcx, digitSpace         
        mov rbx, 32                 ; Se pone imprime al final un espacio como separador
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

        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, rcx        ; Se imprime el contenido de rsi
        mov rdx, 1
        syscall

        mov rcx, [digitSpacePos]
        dec rcx
        mov [digitSpacePos], rcx

        cmp rcx, digitSpace
        jge _printRAXLoop2

        ret

_end:
        ; Se imprime el contenido del array

        mov rax, msg2
        call _print

        mov rax, array
        call _printNums

        

        ; Termina el programa

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall


