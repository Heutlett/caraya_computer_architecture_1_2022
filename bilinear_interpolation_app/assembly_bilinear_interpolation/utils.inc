;       _________________________________________________________________________________________
;
;       Esta libreria contiene macros y rutinas utiles para el algoritmo de interpolacion
;       _________________________________________________________________________________________

;       Importa constantes relevantes
%include "constants.inc"
;       Importa los macros y rutinas para imprimir en consola
%include "prints.inc"

;       _________________________________________________________________________________________
;       Obtiene el valor y el puntero de la matriz de salida en un indice de entrada
;       input:  %1 = index_out
;       output: rax = matrix_out[%1]
;               rcx = puntero al valor de rax en matrix_out 
%macro get_value_and_pointer_matrix_out 1

        mov rax, %1            ; %1 = index_out
        shl rax, 2              ; Se alinea el indice
        add rax, matrix_out     ; Se desplaza el puntero matrix_out a la posicion index_out
        
        mov rcx,rax             ; Se guarda en rcx el puntero para usarlo posteriormente

        mov rax, [rax]          ; rax = matrix_out[index_out]
        and rax, MASK

%endmacro

;       _________________________________________________________________________________________
;       Calcula rax mod rbx, y lo guarda en rax
%macro modulo 0
        mov rdx, 0  
        div rbx     
        mov rax, rdx
%endmacro
;       _________________________________________________________________________________________
;       Calcula el modulo de las filas, columnas y la suma de los mods.
;       input:  %1 = col_out
;               %2 = row_out
;       output: r13 = (%1 mod 3) 
;               r14 = (%2 mod 3) 
;               r15 = (%1 mod 3) + (%2 mod 3) 
%macro mod_col_row 2

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
;       _________________________________________________________________________________________
;       Se actualizan los valores a las variables usadas en la formula de interpolacion
;       input:  %1 = c1
;               %2 = vc1
;               %3 = c2
;               %4 = vc2
;       output: sin salidas
%macro update_interpolation_variables 4

        ; c1 :  Indice conocido 1
        ; c2 :  Indice conocido 2
        ; vc1 : Valor conocido 1
        ; vc2 : Valor conocido 2

        mov [c1],       %1      ; c1    = indexCALC
        mov [vc1],      %2      ; vc1   = matrix_out[c1-1]
        mov [c2],       %3      ; c2    = indexCALC + 3
        mov [vc2],      %4      ; vc2   = matrix_out[c2-1]

%endmacro
;       _________________________________________________________________________________________
;       Calcula y setea las variables de la formula de interpolacion para pixeles horizontales
;       input:  r11 = indexCALC 
;       output: sin salidas
%macro calc_horizontal_interpolation_variables 0

        ; r11 = indexCALC : es el mismo indice index_out pero +1

        ; c1 = indexCALC                | Indice conocido 1
        ; c2 = indexCALC + 3            | Indice conocido 2
        ; vc1 = matrix_out[c1-1]        | Valor conocido 1
        ; vc2 = matrix_out[c2-1]        | Valor conocido 2

        push rbx
        push rcx
        push rdx

        mov rax, r11    
        mov rbx, rax    ; rbx = c1 = indexCALC

        sub rax, 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c1-1]          
        mov rcx, rax    ; rcx = vc1 = matrix_out[c1-1]

        mov rax, r11
        add rax, 3
        mov rdx, rax    ; rdx = c2 = indexCALC + 3

        sub rax, 1      ; rax = c2 - 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c2-1]        

        update_interpolation_variables rbx, rcx, rdx, rax

        pop rdx
        pop rcx
        pop rbx

%endmacro

;       _________________________________________________________________________________________
;       Calcula y setea las variables de la formula de interpolacion para pixeles verticales
;       input:  r8 = col_out
;       output: sin salidas
%macro calc_vertical_interpolation_variables 0

        ; r11 = indexCALC : es el mismo indice index_out pero +1

        ; c1 = (col_out + 1) + vertical_known_counter_c1*ROW_SIZE_OUT   | Indice conocido 1
        ; c2 = (col_out + 1) + vertical_known_counter_c2*ROW_SIZE_OUT   | Indice conocido 2
        ; vc1 = matrix_out[c1-1]        | Valor conocido 1
        ; vc2 = matrix_out[c2-1]        | Valor conocido 2

        push rbx
        push rcx
        push rdx

        mov rax, [vertical_known_counter_c1]    ; rax = vertical_known_counter_c1
        mov rbx, ROW_SIZE_OUT                   ; rbx = ROW_SIZE_OUT
        mul rbx                        ; rax = vertical_known_counter_c1*ROW_SIZE_OUT

        add rax, r8     ; rax = rax + col_out
        add rax, 1      ; rax = rax + 1

        mov rbx, rax    ; rbx = c1 = (col_out + 1) + vertical_known_counter_c1*ROW_SIZE_OUT

        sub rax, 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c1-1]          
        mov rcx, rax    ; rcx = vc1 = matrix_out[c1-1]

        mov rax, [vertical_known_counter_c2]    ; rax = vertical_known_counter_c2
        mov rdx, ROW_SIZE_OUT                   ; rdx = ROW_SIZE_OUT
        mul rdx                                 ; rax = vertical_known_counter_c2*ROW_SIZE_OUT

        add rax, r8     ; rax = rax + col_out
        add rax, 1      ; rax = rax + 1

        mov rdx, rax    ; rdx = c2 = (col_out + 1) + vertical_known_counter_c2*ROW_SIZE_OUT

        sub rax, 1      ; rax = c2 - 1
        shl rax, 2
        add rax, matrix_out            
        mov rax, [rax]  ; rax = matrix_out[c2-1]        

        update_interpolation_variables rbx, rcx, rdx, rax

        pop rdx
        pop rcx
        pop rbx

%endmacro

;       _________________________________________________________________________________________
;       Inserta un nuevo valor a la matriz de salida
;       input:  rcx     = index_out
;               r15w    = int
;       output: sin salidas
%macro insert_new_value_into_matrix_out 0

        call calc_interpolation        ; Calcula el valor desconocido y lo almacena en r15

        ; print_console msgNewValue, 10
        ; push rax
        ; mov rax, r15
        ; printRAX_push_out
        ; print_console new_line,1
        ; print_console new_line,1
        ; pop rax

        mov [rcx], r15w                 ; matrix_out[index_out] = r15w
                                        ; OJO: se usa r15w porque solo se ocupa 1byte

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
        ;call print_matrix

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
        je      _new_row_init        ; Se desplaza a la siguiente fila

_continue_new_row_init_init:

        inc r11         ; col_out = col_out + 1
        inc r9          ; index_out = index_out + 1

        jmp _init_matrix_loop

_new_row_init:

        mov r11, -1     ; col_out = -1
        inc r12         ; row_out = row_out + 1

        jmp _continue_new_row_init_init

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
;       Convierte el numero decimal de rax a ascii y lo almacena en la variable ascii_num
;       ademas guarda en la variable size_ascii_num el tamano del numero
;       input:  rax                     = int
;       output: [size_ascii_num]        = size
convert_dec_to_ascii:

        push_registers

        mov rbx, 0

        mov [ascii_num], rbx

        cmp rax, 10
        jl  _less_10

        cmp rax, 100
        jl  _less_100

        cmp rax, 199
        jg  _bigger_199

        cmp rax, 99
        jg  _bigger_99



_less_10:

        add rax, 48
        mov [ascii_num], rax
        mov rax, 1
        mov [size_ascii_num], rax

        pop_registers

        ret



_less_100:

        mov rbx, rax
        mov rcx, 10
        mov rdx, 0

        div rcx     ; rax/10

        add rax, 48
        mov [ascii_num], rax

        mov r10, ascii_num
        add r10, 1

        add rdx, 48

        mov [r10], rdx

        mov rax, 2
        mov [size_ascii_num], rax

        pop_registers

        ret


_bigger_199:

        mov rbx, 50
        mov [ascii_num], rbx

        sub rax, 200

        mov r10, ascii_num
        add r10, 1

        mov rbx, rax
        mov rcx, 10
        mov rdx, 0

        div rcx     ; rax/10

        add rax, 48
        mov [r10], rax

        inc r10

        add rdx, 48

        mov [r10], rdx

        mov rax, 3
        mov [size_ascii_num], rax

        pop_registers   

        ret


_bigger_99:

        mov rbx, 49
        mov [ascii_num], rbx

        sub rax, 100

        mov r10, ascii_num
        add r10, 1

        mov rbx, rax
        mov rcx, 10
        mov rdx, 0

        div rcx     ; rax/10

        add rax, 48
        mov [r10], rax

        inc r10

        add rdx, 48

        mov [r10], rdx

        mov rax, 3
        mov [size_ascii_num], rax

        pop_registers

        ret
