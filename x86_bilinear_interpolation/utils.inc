;       _________________________________________________________________________________________
;
;       Esta libreria contiene macros y rutinas utiles para el algoritmo de interpolacion
;       _________________________________________________________________________________________

;       Importa constantes relevantes
%include "constants.inc"
;       Importa los macros y rutinas para imprimir en consola
%include "prints.inc"


;       _________________________________________________________________________________________
;       Calcula rax mod rbx, y lo guarda en rax
%macro modulo 0
        mov rdx, 0  
        div rbx     
        mov rax, rdx
%endmacro
;       _________________________________________________________________________________________
;       Calcula 
;       input:  %1 = col_out
;               %2 = row_out
;       output: r13 = (%1 mod 3) 
;               r14 = (%2 mod 3) 
;               r15 = (%1 mod 3) + (%2 mod 3) 
%macro mod_col_row 2

        ;---------------------------------------------------------
        ; Calcula el mod de las filas y columnas
        ;---------------------------------------------------------
        push rax
        push rbx
        push rdx

        mov rax, %1
        mov rbx, 3
        modulo          
        mov r13,rax     ; r13 = col_out % 3

        mov rax, %2
        mov rbx, 3

        modulo          
        mov r14, rax    ; r14 = row_out % 3
        mov r15, 0
        add r15, r13    
        add r15, r14    ; r15 = (col_out % 3) + (row_out % 3)

        pop rdx
        pop rbx
        pop rax

%endmacro



;       ⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬂⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃⬃
;       ⬄                                                                                      ⬄
;       ⬄        CALCULO DE PIXELES DESCONOCIDOS MEDIANTE INTERPOLACION BILINEAL               ⬄
;       ⬄                                                                                      ⬄
;       ⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬀⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁⬁
;       _________________________________________________________________________________________
;       Calcula el valor desconocido mediante la formula de interpolacion bilineal
;
;       Formula: value[i] = (c2-i)*vc1/(c2-c1) + (i-c1)*vc2/(c2-c1)
;
;       input:          r11 = indexCALC
;       output:         r15 = resultado
calc_interpolation:

        push rax
        push rbx
        push rcx
        push rdx
        push r8
        push r9
        push r10
        push r11
        push r12

        mov r8,r11              ; r8 = indexCALC
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

;       _________________________________________________________________________________________
;       
;       Crea la matriz inicial (con valores concidos) a partir del archivo.
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