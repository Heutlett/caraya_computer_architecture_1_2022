;       _________________________________________________________________________________________
;
;       Esta libreria contiene macros y rutinas utiles para el algoritmo de interpolacion
;       _________________________________________________________________________________________

;       Importa constantes relevantes
%include "constants.inc"


;       Print para debuggear el calculo de valores horizontales (1)
%macro print_horizontal_calc_debug 0
        print_console msgDIV, 72
        print_console new_line,1

        print_console msgCol, 8
        mov rax, r8
        printRAX_push_out
        print_console new_line,1

        print_console msgRow, 8
        mov rax, r9
        printRAX_push_out
        print_console new_line,1
        print_console new_line,1

        print_console msgIndex,10
        push rax
        mov rax, r11
        printRAX_push_out
        print_console new_line,1
        print_console new_line,1

        pop rax

        print_matrix_out
%endmacro

;       Print para debuggear el calculo de valores horizontales (2)
%macro print_horizontal_calc_debug2 0
        print_console msgCalcNewValue, 34
        print_console new_line,1
        print_console new_line,1
        print_console msgNewValue, 10

        mov rax, r15
        printRAX_push_out
        print_console new_line,1

        print_console msgGuardaEnI, 21

        mov rax, r10
        printRAX_push_out
        print_console new_line,1
        print_console new_line,1
%endmacro

;       _________________________________________________________________________________________
;       Macro para hacer push de todos los registros menos RAX
%macro push_registers 0
        push rbx        
        push rcx        
        push rdx        
        push r8         
        push r9         
        push r10        
        push r11       
        push r12        
        push r13       
        push r14        
        push r15      
%endmacro

;       _________________________________________________________________________________________
;       Macro para hacer pop de todos los valores de registros que estan en el stack menos RAX
%macro pop_registers 0
        pop r15        
        pop r14        
        pop r13        
        pop r12       
        pop r11      
        pop r10       
        pop r9         
        pop r8         
        pop rdx       
        pop rcx       
        pop rbx             
%endmacro

;       _________________________________________________________________________________________
;       Imprime el valor entero de RAX con respaldo de registros
%macro printRAX_push_out 0

        push_registers
        call print_rax
        pop_registers

%endmacro 

;       _________________________________________________________________________________________
;       Imprime la matriz de salida con respaldo de registros
%macro print_matrix_out 0

        push_registers
        mov rax, matrix_out
        mov rbx, MATRIX_OUT_SIZE
        mov rcx, ROW_SIZE_OUT
        call print_matrix
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


;       _________________________________________________________________________________________
;       
;       Se inicia el proceso de convertir el contenido del archivo en la matriz de salida inicial
;       _________________________________________________________________________________________
create_initial_matrix_out:

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
        je _init_matrix

        jmp _convert_ascii_dec_loop

;       _________________________________________________________________________________________
;       Inicializa la matriz colocando los valores conocidos y en -1 los valores no conocidos
_init_matrix:

        ; Se imprime el contenido del matrix_src
        print_console msg2, 31
        print_console new_line,1
        print_console new_line,1

        mov rax, matrix_src
        mov rbx, MATRIX_SRC_SIZE
        mov rcx, ROW_SIZE_SRC
        call print_matrix

        mov rax, msgDIV
        call print_string

        mov rax, msg3
        call print_string

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
        je      _init_matrix_end        ; se termina la inicializacion de la matriz de salida


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

_init_matrix_end:

        ret

;       _________________________________________________________________________________________
;
;       PRINTS  PRINTS  PRINTS  PRINTS  PRINTS  PRINTS  PRINTS  PRINTS  PRITNTS PRINTS  PRINTS  
;       _________________________________________________________________________________________


;       _________________________________________________________________________________________
;       Imprime en consola la matriz al que apunta el registro rax
;       input:  rax: puntero de la matriz
;               rbx: tamano de la matriz
;               rcx; tamano las filas
;       output: sin salidas
print_matrix:

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
        call print_rax
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
;       Imprime en consola el string al que apunta el registro rax
;       input:  rax: puntero al string
;       output: sin salidas.
print_string:
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
;       Imprime en consola el valor del registro RAX en formato entero
;       input:  rax: entero
;       output: sin salidas
print_rax:
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