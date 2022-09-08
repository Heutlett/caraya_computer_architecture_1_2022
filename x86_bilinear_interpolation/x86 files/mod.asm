%macro modulo 2
       ; calcs eax mod ebx, returns eax
    mov rdx, 0  ; clear higher 32-bits as edx:eax / ebx is calced
    div rbx     
    mov rax, rdx ; the remainder was stored in edx     
%endmacro 

section .text
        global _start

_start:

        mov rax, 1
        mov rbx, 3
        modulo rax, rbx
        mov r8,rax             ; columna mod3


_prueba:

        mov r10, 1

_end:
        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
