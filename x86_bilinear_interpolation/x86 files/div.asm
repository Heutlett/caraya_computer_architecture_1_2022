section .text
        global _start

_start:

        mov rdx, 0
        mov rax, 2
        mov rcx, 3
        div rcx

_prueba:

        mov r10, 1

_end:
        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
