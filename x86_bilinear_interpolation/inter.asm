; Read txt file and save into text array_src

STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

;       Instruccion para imprimir un salto de linea:
;       print_console new_line,1 

%macro push_registers 0
        push rbx        ; rbx
        push rcx        ; rcx
        push rdx        ; rdx
        push r8         ; r8
        push r9         ; r9
        push r10        ; r8
        push r11        ; r9
        push r12        ; r8
        push r13        ; r9
        push r14        ; r8
        push r15        ; r9
%endmacro

%macro pop_registers 0
        pop r15        ; r9
        pop r14        ; r8
        pop r13        ; r9
        pop r12        ; r8
        pop r11        ; r9
        pop r10        ; r8
        pop r9         ; r9
        pop r8         ; r8
        pop rdx        ; rdx
        pop rcx        ; rcx
        pop rbx        ; rbx        
%endmacro

%macro add_2 2

        mov rax, 0
        add rax, %1
        add rax, %2

%endmacro

;       Calcula %1 mod %2 y lo guarda en rdx
%macro modulo 0

       ; calcs eax mod ebx, returns eax
        mov rdx, 0  ; clear higher 32-bits as edx:eax / ebx is calced
        div rbx     
        mov rax, rdx ; the remainder was stored in edx    

        ; push rax
        ; push rbx

        ; mov rax, %1     
        ; mov rbx, %2    
        
        ; mov rdx, 0  
        ; div rbx     
        ; mov rdx, rax

        ; pop rbx
        ; pop rax
%endmacro 

%macro print_console 2
        push_registers
        mov rax, SYS_WRITE
        mov rdi, STDOUT
        mov rsi, %1             ; Se imprime el parametro %1
        mov rdx, %2             ; Size = parametro %2
        syscall
        pop_registers
%endmacro

section .data
        filename        db  "imagen.txt",0

        msgDIV          db  "------------------------------------------------------------------------",0
        msg1            db  "---------------------      Procesando archivo      ---------------------",10,10,"Contenido del archivo:",0
        msg2            db  "Contenido de la matriz inicial:",0
        msg3            db  "--------------------   Creando matriz resultante   ---------------------",0

        new_line        db "",  10          ; Valor de una nueva linea para imprimir
        tab             db "",9
        ; ------------------- CONSTANTES -----------------------------------------
        
        %assign FILE_SIZE       15
        %assign ARRAY_SRC_SIZE      4
        %assign ARRAY_OUT_SIZE  16
        %assign ROW_SIZE_SRC    2
        %assign ROW_SIZE_OUT    4

        %assign MASK            0xff
        %assign ASCII_SPACE     -16
        %assign ASCII_END       -48
        

section .bss
        text            resb    100         ; Contenido del texto leido del archivo

        digitSpace      resb    100         ; Variables usadas para leer numeros enteros
        digitSpacePos   resb    8

        array_src       resb    100         ; Arreglo de elementos de la imagen

        array_out       resb    16

        mod_result      resb    1

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

        mov rax, msgDIV
        call _print

        mov rax, msg1
        call _print

        mov rax, text
        call _print

;   Convierte el contenido del archivo txt de formato ascii a un arreglo de enteros
_convert_ascii_dec:

        mov r12, array_src  ; Puntero array_src
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

        mov [r12], r11      ; Guarda en la posicion r12 del array_src el valor de r11
        inc r12             ; Se mueve el puntero del array_src

        mov r9, 100         ; Resetea el multiplicador
        mov r11, 0          ; Resetea el numero actual

        cmp rcx, ASCII_END  ; Si encuentra el fin
        je _interpolation

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
         
        pop rsi                 
        print_console rsi,rbx   ; Imprime rsi de tamano rbx


        print_console new_line,1
        print_console new_line,1

        ret


; inputs:   rax=array_src
_printNums:

        mov r9, 0           ; Contador
        mov r10, rax        ; Puntero de array_src

_printNumsLoop:

        cmp r9, ARRAY_SRC_SIZE  ; Si contador == ARRAY_SRC_SIZE
        je  _printNumsEnd

        mov rax, [r10]
        and rax, MASK

        call _printRAX

        inc r10

        add r9,1

        jmp _printNumsLoop

_printNumsEnd:

        print_console new_line,1
        print_console new_line,1

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

        print_console rcx, 1

        mov rcx, [digitSpacePos]
        dec rcx
        mov [digitSpacePos], rcx

        cmp rcx, digitSpace
        jge _printRAXLoop2

        ret

print_array:

        push rax

        mov rax, msg2
        call _print

        mov rax, array_src
        call _printNums

        pop rax

        ret



_interpolation:

        ; Se imprime el contenido del array_src
        call print_array

        mov rax, msgDIV
        call _print

        mov rax, msg3
        call _print


_init_matrix:

        mov rbx, array_src      ; Puntero array_src
        mov rcx, array_out      ; Puntero array_out
        mov r8, 0               ; index_src
        mov r9, 0               ; index_out = c      
        mov r10, ROW_SIZE_OUT   ; last_index_out
        sub r10, 1
        mov r11, 0              ; col_out
        mov r12, 0              ; row_out


_init_matrix_loop:

        cmp r9, ARRAY_OUT_SIZE
        je      _end


        mov rax,[rcx]
        and rax, MASK


        ; calcs eax mod ebx, returns eax
        push rax
        push rbx
        push rdx

        mov rax, r11
        mov rbx, 3
        modulo 
        mov r13,rax             ; columna mod3

        mov rax, r12
        mov rbx, 3

        modulo           ; fila mod3
        mov r14, rax


        pop rdx
        pop rbx
        pop rax
        

        add r13,r14

        cmp r13, 0              ; if(col_out%3==0 and row_out%3==0):
        je      _known_value    ; Coloca en la matriz inicial un valor conocido
        jne     _null_value

_continue_columns:

        cmp r11, r10            ; if (col_out == last_index_out)
        je      _new_row        ; nueva fila

_continue_new_row:

        inc r11                 ; col_out = col_out + 1

        inc r9
        

        jmp _init_matrix_loop

_new_row:

        print_console new_line,1

        mov r11, -1              ; col_out = -1
        inc r12                  ; row_out = row_out +1

        jmp _continue_new_row

_known_value:

        push rbx        ; array_src     
        push rcx        ; array_out
        push rax

        add rbx, r8     ; addressing
        add rcx, r9     ; addressing

        mov rax, [rbx]
        and rax, MASK

        mov [rcx], rax

        push_registers
        call _printRAX
        pop_registers

        print_console tab,1

        pop rax
        pop rcx
        pop rbx

        inc r8          ; index_src = index_src + 1

        jmp _continue_columns

_null_value:

        push rax
        mov rax, 0

        push_registers
        call _printRAX
        pop_registers

        print_console tab,1

        jmp _continue_columns


; mov rax, 7
; mov rbx, 3

; modulo rax, rbx
; mov rax, [mod_result]
; call _printRAX


_end:



        ; Termina el programa

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall


