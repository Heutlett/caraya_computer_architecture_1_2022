;       Directivas para llamadas al sistema
STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

section .data

        n dd 83521 

        matrix_out       TIMES 83521 dd -1      ; Arreglo de salida

        matrix_src       TIMES 83521 dd -1      ; Arreglo de salida


section .text
        global _start


_start:


        mov rax, 83521
        mov rbx, 0
        mov rcx, matrix_out
        mov r10, 5

_ciclo:

        cmp rbx, 83521
        je _end

        mov [rcx], r10

        add rcx, 4

        inc rbx

        jmp _ciclo
        


_end:

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall