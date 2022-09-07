section .text
        global _start

_start:

        mov edx, 550
        mov eax, 100
        mov ecx, 10
        div ecx

_prueba:

        mov r10, 1

_end:
        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
