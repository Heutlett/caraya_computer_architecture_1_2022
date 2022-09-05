; Read txt file and save into text array

section .data
        filename    db  "imagen.txt",0

        msg1        db "Contenido inicial del archivo:",10

        new_line    db "",10

section .bss
        text    resb    100

        array   resb    100

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
        mov rdx, 11          ; size_t
        syscall



_convert_hex_dec:

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

_end:
        ; Cierra el archivo

        mov rax, 3
        pop rdi
        syscall

        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall


