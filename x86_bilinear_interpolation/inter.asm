;       Autor:  Carlos Adrian Araya Ramirez
;       Email:  adrian.araya.420@gmail.com
;       _________________________________________________________________________________________
;
;       Este programa aplica el algoritmo de interpolacion bilineal a una matriz
;       _________________________________________________________________________________________

;       utils.inc:      Libreria que contiene macros, rutinas y constantes requeridas 
%include "utils.inc"    

;       Directivas para llamadas al sistema
STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

section .data
        filename       db  "imagen2x2.txt",0
        ;filename       db  "imagen3x3.txt",0
        ;filename       db  "imagen4x4.txt",0

        msgDIV          db  "------------------------------------------------------------------------",0
        msg1            db  "---------------------      Procesando archivo      ---------------------",10,10,"Contenido del archivo:",0
        msg2            db  "Contenido de la matriz inicial:",0
        msg3            db  "--------------------   Creando matriz resultante   ---------------------",0
        msg4            db  "Valores conocidos:",0
        msg5            db  "Valores horizontales:",0
        msgCol          db  "col_out: ",0
        msgRow          db  "row_out: ",0
        msgC1           db  "c1: ",0
        msgC2           db  "c2: ",0
        msgVC1          db  "vc1: ",0
        msgVC2          db  "vc2: ",0
        msgIndex        db  "indexCALC: ",0   
        msgModCol       db  "modCol: ",0
        msgModRow       db  "modRow: ",0
        msgNewValue     db  "NewValue: ",0
        msgPrueba       db  "prueba", 0    
        msgCalcNewValue db  "Calculando nuevo valor desconocido",0
        msgGuardaEnI    db  "Guarda en el indice: ",0
        msgMatrixActual db  "Matriz actual antes de calcular",0

        new_line        db  "",  10             ; Valor de una nueva linea para imprimir
        tab             db  "",9                ; Valor de un tab para imprimir
        

section .bss
        text            resb    100     ; Contenido del texto leido del archivo

        digitSpace      resb    100     ; Variables usadas para leer numeros enteros
        digitSpacePos   resb    8

        c1              resb    8       ; Variable para guardar el indice del valor conocido 1
        c2              resb    8       ; Variable para guardar el indice del valor conocido 2
        vc1             resb    8       ; Variable para guardar el contenido del valor conocido 1
        vc2             resb    8       ; Variable para guardar el contenido del valor conocido 2

        matrix_src       resb    100     ; Arreglo de elementos de la imagen
        matrix_out       resd    16      ; Arreglo de salida

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
        call print_string

        mov rax, msg1
        call print_string

        mov rax, text
        call print_string

        call create_initial_matrix_out  ; Ejecuta la rutina que crea la matriz inicial
                                        ; con los valores conocidos colocados
;       _________________________________________________________________________________________
;
;                               INICIO DEL ALGORITMO DE INTERPOLACION
;       _________________________________________________________________________________________

;       Calcula los valores horizontales desconocidos
_bilinear_interpolation:

        ;       Imprime la matriz_out con los valores conocidos
        mov rax, msg4
        call print_string
        print_matrix_out

        mov rbx, matrix_out     ; Puntero a matrix_out

        mov r8, 0               ; col_out
        mov r9, 0               ; row_out

        mov r10, 0              ; index_out = c
        mov r11, 1              ; indexCALC

_bilinear_interpolation_calc_loop:

        cmp r10, MATRIX_OUT_SIZE        ; IF (index_out == MATRIX_OUT_SIZE)
        je      _vertical_values        ; Finaliza el calculo de los valores horizontales    

        ; Calcula el mod de las filas y columnas
        ; Guarda en r13 = col_out%3, r14 = row_out%3, r15 = col_out%3 + row_out%3
        mod_col_row r8,r9

        

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_horizontal_calc_debug                                                     ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        cmp r15, 0      ; IF (col_out % 3 == 0 and row_out % 3 == 0)

        je      _horizontal_null_value

_continue_horizontal_null_value:

        ; Primera condicion requerida para que el index_out corresponda a un valor desconocido horizontal
        cmp r13, 0      ; IF (col_out % 3 == 0)         
        jne     _put_new_value_1

_continue_put_new_value:

        cmp r8, LAST_INDEX_OUT          ; IF (col_out == LAST_INDEX_OUT)
        je      _new_row_horizontal     ; Se desplaza una fila adelante

_continue_new_row_horizontal:

        inc r8          ; col_out = col_out + 1
        inc r10         ; index_out = index_out + 1
        inc r11         ; indexCALC = indexCALC + 1

        jmp _bilinear_interpolation_calc_loop

_new_row_horizontal:

        mov r8, -1      ; col_out = -1
        inc r9          ; row_out = row_out + 1

        jmp _continue_new_row_horizontal

_horizontal_null_value:

        ; Se asignan los valores a las variables usadas en la formula de interpolacion

        ; indexCALC : es el mismo indice index_out pero +1

        ; c1 = indexCALC                | Indice conocido 1
        ; c2 = indexCALC + 3            | Indice conocido 2
        ; vc1 = matrix_out[c1-1]        | Valor conocido 1
        ; vc2 = matrix_out[c2-1]        | Valor conocido 2

        push rbx
        push rcx
        push rdx

        mov rax, r11
        and rax, MASK    
        mov rbx, rax    ; rbx = c1 = indexCALC

        sub rax, 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c1-1]          
        and rax, MASK
        mov rcx, rax    ; rcx = vc1 = matrix_out[c1-1]

        mov rax, r11
        add rax, 3
        and rax, MASK
        mov rdx, rax    ; rdx = c2 = indexCALC + 3

        sub rax, 1      ; rax = c2 - 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c2-1]        
        and rax, MASK

        update_interpolation_variables rbx, rcx, rdx, rax

        pop rdx
        pop rcx
        pop rbx

        jmp _continue_horizontal_null_value

;       _________________________________________________________________________________________
;       Para que el indice actual de matrix_out corresponda a un valor desconocido horizontal
;       se debe cumplir la siguiente condicion: IF (col_out % 3 != 0 and row_out % 3 == 0)
;       si se llego hasta aqui ya se cumplio la primera condicion (col_out % 3 != 0)
_put_new_value_1:

        cmp r14, 0              ; IF (row_out % 3 == 0)
        je _put_new_value_2     ; Se cumple la segunda condicion

        jmp _continue_put_new_value

_put_new_value_2:

        mov rax, r10            ; rax = index_out
        shl rax, 2              ; Se alinea el indice
        add rax, matrix_out     ; Se desplaza el puntero matrix_out a la posicion index_out
              
        mov rcx,rax             ; Se guarda en rcx el puntero para usarlo posteriormente

        mov rax, [rax]          ; rax = matrix_out[index_out]
        and rax, MASK

        ; Esta condicion se debe cambiar, debe ser == -1
        cmp rax, 0              ; IF (matrix_out[index_out] == 0)
        je _put_new_value_3     ; Si se cumple significa que es un valor desconocido que se debe calcular

        jmp _continue_put_new_value

_put_new_value_3:

        call calc_interpolation        ; Calcula el valor desconocido y lo almacena en r15

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_horizontal_calc_debug2                                                    ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        mov [rcx], r15w                 ; matrix_out[index_out] = r15w
                                        ; OJO: se usa r15w porque solo se ocupa 1byte

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_matrix_out                                                                ; DEBUG
        print_console new_line,1
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        jmp _continue_put_new_value

;       _________________________________________________________________________________________
;                       Se inicia el calculo de los valores horizontales
_vertical_values:

        mov rax, msg5
        call print_string
        
        print_matrix_out

_end:

        ; Termina el programa

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
