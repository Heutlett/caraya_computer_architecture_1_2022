; Read txt file and save into text array

section .data
        filename    db  "imagen.txt",0

        msg1        db "Contenido inicial del archivo:",10

        new_line    db "",10

        array TIMES     100 db 0b    ; Arreglo de resultados
                                    ; Son 11 espacios para guardar primero la seed
                                    ; y luego los 10 randoms generados

section .bss
        text    resb    100



section .text
        global _start

_start:

        ; Se abre el archivo

        mov rax,    2       ; SYS_OPEN
        mov rdi,    filename
        mov rsi,    0
        mov rdx,    0
        syscall

        ; Se lee el archivo

        push    rax

        mov rdi, rax
        mov rax, 0          ; SYS_READ
        mov rsi, text
        mov rdx, 15          ; size_t
        syscall



_print_file:

        ;mov rax,    text

        mov rax, 1
        mov rdi, 1
        mov rsi, msg1   ; Imprime: "Contenido inicial del archivo:"
        mov rdx, 32

        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, text   ; Imprime el contenido del archivo
        mov rdx, 100

        syscall

        mov rax, 1
        mov rdi, 1
        mov rsi, new_line   ; Imprime un salto de linea
        mov rdx, 1

        syscall


        mov r8, 15  ; N
        mov rdx, 0  ; Contador

        mov rax, array  ; Puntero array
        mov rbx, text   ; Puntero txt

_convert_ascii_dec:

        cmp rdx, r8        ; Contador == N

        je _end             ; Si Contador == 100, salta a end

        mov rcx, [rbx]  ; Guarda en rdx el valor del txt en la posicion del puntero rbx

        inc rbx         ; Se mueve el puntero de txt

        mov [rax], rcx  ; Guarda en rdx array el valor de rdx en la posicion del puntero rax

        inc rax         ; Se mueve el puntero array

        add rdx, 1      ; se aumenta el contador

        jmp _convert_ascii_dec




_end:
        ; Cierra el archivo

        mov rax, 3
        pop rdi
        syscall

        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall


