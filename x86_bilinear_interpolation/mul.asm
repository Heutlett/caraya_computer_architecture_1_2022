section .text
        global _start

_start:

        mov eax, 100
        mov ecx, 3
        mul ecx

_prueba:

        mov r10, 1

_end:
        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
