section .data


section .bss

        num       resb    128
        

section .text
        global _start

_start:

        mov rax, 1
        mov [num], rax

        ;movapd xmm1,[num]

        movq xmm0, rax

        mov rax, 2

        movq xmm1, rax

        divss xmm0, xmm1

        ;mov rbx, 2
        ;mov [num], rbx
        
        ;movapd xmm2,[num]

        ;mulps xmm1, xmm2

        ;addsd xmm0,xmm1
        

        mov rdx, 0
        mov rax, num
        mov rcx, 3
        div rcx

_prueba:

        mov r10, 1

_end:
        ; Termina el programa

        mov rax, 60
        mov rdi, 0
        syscall
