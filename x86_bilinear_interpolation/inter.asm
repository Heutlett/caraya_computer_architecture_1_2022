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
        msg6            db  "▶ Se colocara un nuevo valor"

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

        vertical_known_counter_c1 resb 8
        vertical_known_counter_c2 resb 8

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

        ;       Inicializa contadores de posicion de valores conocidos
        ;       para calculo vertical
        mov rax, 0
        mov [vertical_known_counter_c1], rax
        mov rax, 3
        mov [vertical_known_counter_c2], rax


_bilinear_interpolation_vertical_calc:

        cmp r10, MATRIX_OUT_SIZE        ; IF (index_out == MATRIX_OUT_SIZE)
        je      _bilinear_interpolation_horizontal_calc        ; Finaliza el calculo de los valores horizontales    

        ; Calcula el mod de las filas y columnas
        ; Guarda en r13 = col_out%3, r14 = row_out%3, r15 = col_out%3 + row_out%3
        mod_col_row r8,r9

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_calc_debug                                                                ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

_continue_put_new_value:

;       ---------------------- vertical -------------------
        cmp r13, 0      ; IF (col_out % 3 == 0)         
        je     _put_new_vertical_value_cond

_continue_put_new_vertical_value:

        cmp r8, LAST_INDEX_OUT          ; IF (col_out == LAST_INDEX_OUT)
        je      _new_row     ; Se desplaza una fila adelante

_continue_new_row:

        inc r8          ; col_out = col_out + 1
        inc r10         ; index_out = index_out + 1
        inc r11         ; indexCALC = indexCALC + 1

        jmp _bilinear_interpolation_vertical_calc

_new_row:

        mov r8, -1      ; col_out = -1
        inc r9          ; row_out = row_out + 1

        mod_col_row r8,r9

        cmp r14, 0      ; IF (row_out % 3 == 0)
        je      _increase_vertical_known_counters

        jmp _continue_new_row

_increase_vertical_known_counters:

        push rax
        mov rax, [vertical_known_counter_c1]
        add rax, 3
        mov [vertical_known_counter_c1], rax

        mov rax, [vertical_known_counter_c2]
        add rax, 3
        mov [vertical_known_counter_c2], rax
        pop rax

        jmp _continue_new_row

_put_new_value:

        print_console msg6, 31
        print_console new_line,1

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_calc_debug2                                                    ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        ;       Inserta un nuevo valor a matrix_out
        ;       input: rcx  = index_out desplazado
        ;              r15w = entero a insertar
        insert_new_value_into_matrix_out

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_matrix_out                                                                ; DEBUG
        print_console new_line,1
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        jmp _continue_put_new_value

;       _________________________________________________________________________________________
;                       Se inicia el calculo de los valores horizontales
_put_new_vertical_value_cond:

        prueba1:
        cmp r14, 0                              ; IF (row_out % 3 != 0)
        jne _put_new_vertical_value             ; Se cumple la segunda condicion


        jmp _continue_put_new_vertical_value    ; No se cumple la segunda condicion

_put_new_vertical_value:

        calc_vertical_interpolation_variables

        

        ;       Almacena en rax el valor de matrix_out[r10] y en rcx el puntero
        get_value_and_pointer_matrix_out r10

        ; Esta condicion se debe cambiar, debe ser == -1
        cmp rax, 0              ; IF (matrix_out[index_out] == 0)
        je _put_new_value     ; Si se cumple significa que es un valor desconocido que se debe calcular


        jmp _continue_put_new_vertical_value


;       Calcula los valores horizontales desconocidos
_bilinear_interpolation_horizontal_calc:

        mov rbx, matrix_out     ; Puntero a matrix_out

        mov r8, 0               ; col_out
        mov r9, 0               ; row_out

        mov r10, 0              ; index_out = c
        mov r11, 1              ; indexCALC

_bilinear_interpolation_calc_loop:

        cmp r10, MATRIX_OUT_SIZE        ; IF (index_out == MATRIX_OUT_SIZE)
        je      _end        ; Finaliza el calculo de los valores horizontales    

        ; Calcula el mod de las filas y columnas
        ; Guarda en r13 = col_out%3, r14 = row_out%3, r15 = col_out%3 + row_out%3
        mod_col_row r8,r9

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        ;print_calc_debug                                                                ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        cmp r13, 0      ; IF (col_out % 3 == 0 and row_out % 3 == 0)

        je      _set_horizontal_inter_variables

_continue_set_horizontal_inter_variables:

        ; Primera condicion requerida para que el index_out corresponda a un valor desconocido horizontal
        cmp r13, 0      ; IF (col_out % 3 != 0)         
        jne     _put_new_horizontal_value

_continue_put_new_horizontal_value:

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

        mod_col_row r8,r9

        jmp _continue_new_row_horizontal


_set_horizontal_inter_variables:

        ; Se asignan los valores a las variables usadas en la formula de interpolacion
        calc_horizontal_interpolation_variables

        jmp _continue_set_horizontal_inter_variables

;       _________________________________________________________________________________________
;       Para que el indice actual de matrix_out corresponda a un valor desconocido horizontal
;       se debe cumplir la siguiente condicion: IF (col_out % 3 != 0 and row_out % 3 == 0)
;       si se llego hasta aqui ya se cumplio la primera condicion (col_out % 3 != 0)
_put_new_horizontal_value_cond:

        cmp r14, 0              ; IF (row_out % 3 == 0)
        je _put_new_horizontal_value     ; Se cumple la segunda condicion

        jmp _continue_put_new_horizontal_value

_put_new_horizontal_value:

        ;       Almacena en rax el valor de matrix_out[r10] y en rcx el puntero
        get_value_and_pointer_matrix_out r10

        ; Esta condicion se debe cambiar, debe ser == -1
        cmp rax, 0              ; IF (matrix_out[index_out] == 0)
        je _put_new_value_horizontal     ; Si se cumple significa que es un valor desconocido que se debe calcular

        jmp _continue_put_new_horizontal_value

_put_new_value_horizontal:

        print_console msg6, 31
        print_console new_line,1

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_calc_debug2                                                    ; DEBUG
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        ;       Inserta un nuevo valor a matrix_out
        ;       input: rcx  = index_out desplazado
        ;              r15w = entero a insertar
        insert_new_value_into_matrix_out

;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
        print_matrix_out                                                                ; DEBUG
        print_console new_line,1
;       ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        jmp _continue_put_new_horizontal_value

_end:

        mov rax, msg5
        call print_string
        
        print_matrix_out

        ; Termina el programa

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
