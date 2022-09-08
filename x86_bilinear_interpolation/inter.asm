;       Directivas para llamadas al sistema

STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

;       _________________________________________________________________________________________
;       Macro para hacer push de todos los registros menos RAX
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

;       _________________________________________________________________________________________
;       Macro para hacer pop de todos los valores de registros que estan en el stack menos RAX
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

;       _________________________________________________________________________________________
;       Imprime el valor entero de RAX con respaldo de registros
%macro printRAX_push_out 0

        push_registers
        call _printRAX
        pop_registers

%endmacro 

;       _________________________________________________________________________________________
;       Imprime la matriz de salida con respaldo de registros
%macro print_matrix_out 0

        push_registers
        mov rax, matrix_out
        mov rbx, MATRIX_OUT_SIZE
        mov rcx, ROW_SIZE_OUT
        call _print_matrix
        pop_registers

%endmacro

;       _________________________________________________________________________________________
;       Calcula rax mod rbx, y lo guarda en rax
%macro modulo 0
        mov rdx, 0  
        div rbx     
        mov rax, rdx
%endmacro       

;       _________________________________________________________________________________________
;       Imprime en pantalla, %1 = string, %2 = tamano, respalda registros
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
        msg4            db  "Valores conocidos:",0
        msg5            db  "Valores horizontales:",0
        msgCol          db  "col_out: ",0
        msgRow          db  "row_out: ",0
        msgC1           db  "c1: ",0
        msgC2           db  "c2: ",0
        msgVC1          db  "vc1: ",0
        msgVC2          db  "vc2: ",0
        msgIndex        db  "index: ",0   
        msgModCol       db  "modCol: ",0
        msgModRow       db  "modRow: ",0
        msgNewValue     db  "NewValue",0
        msgPrueba       db  "prueba", 0    

        new_line        db  "",  10             ; Valor de una nueva linea para imprimir
        tab             db  "",9                ; Valor de un tab para imprimir

        ; _____________________________ CONSTANTES _________________________________________
        
        %assign FILE_SIZE               15
        %assign MATRIX_SRC_SIZE         4
        %assign MATRIX_OUT_SIZE         16
        %assign ROW_SIZE_SRC            2
        %assign ROW_SIZE_OUT            4
        %assign LAST_INDEX_OUT          3
        

        %assign MASK            0xff
        %assign ASCII_SPACE     -16
        %assign ASCII_END       -48
        

section .bss
        text            resb    100     ; Contenido del texto leido del archivo

        digitSpace      resb    100     ; Variables usadas para leer numeros enteros
        digitSpacePos   resb    8

        matrix_src       resb    100     ; Arreglo de elementos de la imagen
        matrix_out       resd    16      ; Arreglo de salida

        c1              resb    8       ; Variable para guardar el indice del valor conocido 1
        c2              resb    8       ; Variable para guardar el indice del valor conocido 2
        vc1             resb    8       ; Variable para guardar el contenido del valor conocido 1
        vc2             resb    8       ; Variable para guardar el contenido del valor conocido 2

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
        call _print_string

        mov rax, msg1
        call _print_string

        mov rax, text
        call _print_string

;       _________________________________________________________________________________________
;       Convierte el contenido del archivo txt de formato ascii a un arreglo de enteros
_convert_ascii_dec:

        mov r12, matrix_src     ; Puntero matrix_src
        mov rbx, text           ; Puntero txt
        mov r9, 100             ; Multiplicador
        mov r11, 0              ; Num

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

        mov [r12], r11          ; Guarda en la posicion r12 del matrix_src el valor de r11

        add r12, 4              ; Se desplaza el puntero del matrix_src      

        mov r9, 100             ; Resetea el multiplicador
        mov r11, 0              ; Resetea el numero actual

        cmp rcx, ASCII_END      ; Si encuentra el fin
        je _interpolation

        jmp _convert_ascii_dec_loop

;       _________________________________________________________________________________________
;       Imprime en consola el string al que apunta el registro rax
;       input:  rax: puntero al string
;       output: sin salidas.
_print_string:
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

;       _________________________________________________________________________________________
;       Imprime en consola la matriz al que apunta el registro rax
;       input:  rax: puntero de la matriz
;               rbx: tamano de la matriz
;               rcx; tamano las filas
;       output: sin salidas
_print_matrix:

        push r9
        push r10
        push r11

        mov r9, 0           ; Contador
        mov r10, rax        ; Puntero de la matriz

_print_matrix_Loop:

        cmp r9, rbx  ; Si contador == MATRIX_SRC_SIZE
        je  _print_matrix_end

        mov rax, [r10]
        and rax, MASK

        push_registers
        call _printRAX
        pop_registers

        print_console tab,1

        add r10,4
        add r9,1

        push rax
        push rbx

        mov rax, r9
        mov rbx, rcx
        modulo          

        cmp rax, 0
        je _print_new_row

_continue_print:

        pop rbx
        pop rax

        jmp _print_matrix_Loop

_print_new_row:

        print_console new_line,1

        jmp _continue_print

_print_matrix_end:

        pop r11
        pop r10
        pop r9

        print_console new_line,1

        ret 
;       _________________________________________________________________________________________
;       Imprime en consola el valor del registro RAX en formato entero
;       input:  rax: entero
;       output: sin salidas
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

;       _________________________________________________________________________________________
;                               INICIO DEL ALGORITMO DE INTERPOLACION
_interpolation:

        ; Se imprime el contenido del matrix_src
        print_console msg2, 31
        print_console new_line,1
        print_console new_line,1

        mov rax, matrix_src
        mov rbx, MATRIX_SRC_SIZE
        mov rcx, ROW_SIZE_SRC
        call _print_matrix

        mov rax, msgDIV
        call _print_string

        mov rax, msg3
        call _print_string

;       _________________________________________________________________________________________
;       Inicializa la matriz colocando los valores conocidos y en -1 los valores no conocidos
_init_matrix:

        mov rbx, matrix_src     ; Puntero matrix_src
        mov rcx, matrix_out     ; Puntero matrix_out
        mov r8, 0               ; index_src
        mov r9, 0               ; index_out = c      
        mov r11, 0              ; col_out
        mov r12, 0              ; row_out

;       _________________________________________________________________________________________
;                             Se itera sobre la matriz de salida matrix_out
_init_matrix_loop:

        cmp r9, MATRIX_OUT_SIZE         ; IF (index_out == MATRIX_OUT_SIZE)
        je      _horizontal_calc        ; se termina la inicializacion de la matriz de salida


        ; Calcula el mod de las filas y columnas y lo suma
        push rax
        push rbx
        push rdx

        mov rax, r11
        mov rbx, 3
        modulo          ; col_out % 3
        mov r13,rax     

        mov rax, r12
        mov rbx, 3

        modulo          ; row_out % 3
        add r13, rax    ; r13 = (col_out % 3) + (row_out % 3)

        pop rdx
        pop rbx
        pop rax
        
        cmp r13, 0              ; IF (col_out % 3 == 0 and row_out % 3 == 0)
        je      _known_value    ; Agrega un valor conocido a matrix_out

_continue_columns:

        cmp r11, LAST_INDEX_OUT ; IF (col_out == LAST_INDEX_OUT)
        je      _new_row        ; Se desplaza a la siguiente fila

_continue_new_row:

        inc r11         ; col_out = col_out + 1
        inc r9          ; index_out = index_out + 1

        jmp _init_matrix_loop

_new_row:

        mov r11, -1     ; col_out = -1
        inc r12         ; row_out = row_out + 1

        jmp _continue_new_row

;       _________________________________________________________________________________________
;       Encuentra un index_out al que le corresponde un valor conocido:  
;               matrix_out[index_out] = matrix_src[index_src]
_known_value:

        push rbx        
        push rcx        
        push rax
        push rdx

        mov rdx, r8     ; rdx = index_src
        shl rdx, 2      ; Alinea el index_src

        add rbx, rdx    ; Desplaza el puntero matrix_src a la posicion index_src

        mov rdx, r9     ; rdx = index_out
        shl rdx, 2      ; Alinea el index_out 

        add rcx, rdx    ; Desplaza el puntero matrix_out a la posicion index_out
        

        mov eax, [rbx]  ; rax = matrix_src[index_src] 
        mov [rcx], eax  ; matrix_out[index_out] = rax

        pop rdx
        pop rax
        pop rcx
        pop rbx
        
        inc r8          ; index_src = index_src + 1

        jmp _continue_columns

;       _________________________________________________________________________________________
;                       Se inicia el calculo de los valores horizontales
_horizontal_calc:

        ;       Imprime la matriz_out con los valores conocidos
        mov rax, msg4
        call _print_string
        print_matrix_out

        mov rbx, matrix_out     ; Puntero a matrix_out

        mov r8, 0               ; col_out
        mov r9, 0               ; row_out

        mov r10, 0              ; index_out = c
        mov r11, 1              ; indexCALC

_horizontal_calc_loop:

        cmp r10, MATRIX_OUT_SIZE        ; IF (index_out == MATRIX_OUT_SIZE)
        je      _vertical_values        ; Finaliza el calculo de los valores horizontales    

        ; Calcula el mod de las filas y columnas
        push rax
        push rbx
        push rdx

        mov rax, r8
        mov rbx, 3
        modulo          
        mov r13,rax     ; r13 = col_out % 3

        mov rax, r9
        mov rbx, 3

        modulo          
        mov r14, rax    ; r14 = row_out % 3
        mov r15, 0
        add r15, r13    
        add r15, r14    ; r15 = (col_out % 3) + (row_out % 3)

        pop rdx
        pop rbx
        pop rax

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

        jmp _horizontal_calc_loop

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

        mov rax, r11    
        mov [c1], rax   ; c1 = indexCALC

        sub rax, 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c1-1]          
        and rax, MASK
        mov [vc1], rax  ; vc1 = matrix_out[c1-1]

        mov rax, r11
        add rax, 3
        mov [c2], rax   ; c2 = indexCALC + 3

        sub rax, 1      ; rax = c2 - 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c2-1]        
        and rax, MASK
        mov [vc2], rax  ; vc2 = matrix_out[c2-1]

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

        shl rax, 2

        add rax, matrix_out

        mov rcx, 0
        mov rcx,rax             

        mov rax, [rax]
        and rax, MASK

        cmp rax, 0
        je _put_new_value_3

        jmp _continue_put_new_value

_put_new_value_3:

        call _calc_interpolation

        mov [rcx], r15w

        jmp _continue_put_new_value

_calc_interpolation:

;   Parametros:     c1:         indice conocido1
;                   c2:         indice conocido2
;                   i: r8         indice numero a calcular
;                   vc1:        valor del conocido1
;                   vc2:        valor del conocido2

        push rax
        push rbx
        push rcx
        push rdx
        push r8
        push r9
        push r10
        push r11
        push r12


        mov r8,r11              ; r8 = index
        mov r9, [c1]
        and r9, MASK
        mov r10, [vc1]
        and r10, MASK
        mov r11, [c2]
        and r11, MASK
        mov r12, [vc2]
        and r12, MASK

        ; ((c2-i)/(c2-c1))*vc1
        mov rcx, 0     
        mov rcx, r11
        sub rcx, r8     ;(c2-i)         

        mov rbx, 0
        mov rbx, r11
        sub rbx, r9     ;(c2-c1)       

        ; (c2-i)*vc1
        mov rax, r10    ; (vc1)
        mul rcx         
        mov rcx, rax    ; (c2-i)*vc1

        ; (c2-i)*vc1/(c2-c1)
        mov rdx, 0      ; 0 utilizado en la division para evitar error
        mov rax, rcx    ; (c2-i)*vc1
        div rbx         ; rax/(c2-c1)
        mov rbx, rax    ; ((c2-i)/(c2-c1))

        mov r15, rbx    ; r15 = ((c2-i)/(c2-c1))*vc1

        ; ((i-c1)/(c2-c1))*vc2
        mov rcx, 0      ; der
        mov rcx, r8
        sub rcx, r9     ;(i-c1)

        mov rbx, 0
        mov rbx, r11
        sub rbx, r9     ;(c2-c1)

        ; (i-c1)*vc2
        mov rax, r12    ; (vc2)
        mul rcx         
        mov rcx, rax    ; (i-c1)*vc2

        ; (i-c1)*vc2/(c2-c1)
        mov rdx, 0      ; 0 utilizado en la division para evitar error
        mov rax, rcx    ; (i-c1)*vc2
        div rbx         ; rax/(c2-c1)

        mov rbx, rax    ; rbx = (i-c1)*vc2/(c2-c1)

        add r15, rax    ; r15 = Resultado 
        and r15, MASK

        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        pop rdx
        pop rcx
        pop rbx
        pop rax

        ret

_vertical_values:

        mov rax, msg5
        call _print_string
        
        print_matrix_out

_end:

        

        ; Termina el programa

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall
