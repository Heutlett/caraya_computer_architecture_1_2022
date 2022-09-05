; Read txt file and save into text array

section .data
        filename    db  "imagen.txt",0

section .bss
        text resb   18

section .text
        global _start

_start:

        mov rax,    2       ; SYS_OPEN
        mov rdi,    filename
        mov rsi,    0
        mov rdx,    0
        syscall

_prueba:

        push    rax

        mov rdi, rax
        mov rax, 0          ; SYS_READ
        mov rsi, text
        mov rdx, 11          ; size_t
        syscall

_end:

        mov rax, 3
        pop rdi
        syscall

        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
