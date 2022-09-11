
;       _________________________________________________________________________________________
;
;       Esta libreria contiene macros y rutinas para imprmir en consola
;       _________________________________________________________________________________________

;       Importa constantes relevantes
%include "constants.inc"

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

;       Print para debuggear el calculo de valores horizontales (1)
%macro print_calc_debug 0
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

        ; print_matrix_out
%endmacro

;       Print para debuggear el calculo de valores horizontales (2)
%macro print_calc_debug2 0

        print_console msgGuardaEnI, 21

        mov rax, r10
        printRAX_push_out
        print_console new_line,1
        print_console new_line,1
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
        ; Modulo
        mov rdx, 0  
        div rbx     
        mov rax, rdx      

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