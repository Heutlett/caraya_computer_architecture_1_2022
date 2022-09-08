section .data

        


section .bss


        array   resb    16



section .text
        global _start

_start:

        mov r10, array

        mov rax, 1

        mov [r10], rax

        mov rcx, [r10]

        add r10, 4

_prue:

        mov rax, 2

        mov [r10], rax

        mov rcx, [r10]



        mov r10, array

        mov eax, 255

        mov [r10], eax

        mov rcx, [r10]


_prueba:

        mov r10, 1

_end:
        ; Termina el programa


        mov rax, 60
        mov rdi, 0
        syscall
