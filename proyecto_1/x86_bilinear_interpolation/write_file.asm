
;       Directivas para llamadas al sistema
STDOUT      equ 1

SYS_OPEN    equ 2
SYS_CLOSE   equ 3

SYS_READ    equ 0
SYS_WRITE   equ 1

O_RDONLY    equ 0

SYS_EXIT    equ 60

O_WRONLY    equ 1

O_CREAT     equ 64



section .data

        filename       db  "result.txt",0
        
        num           db 142

        %assign MASK            0xff


section .bss

        ascii_num       resd    3   
        size_ascii_num  resb    8     

section .text
        global _start

_start:

        mov eax, 10        ; system call 10: unlink
        mov ebx, filename ; file name to unlink
        int 80h            ; call into the system

        mov rax, SYS_OPEN
        mov rdi, filename
        mov rsi, O_WRONLY+O_CREAT
        mov rdx, 0644o
        syscall


        mov rdi, rax

        mov rax, [num]

        call convert_dec_to_ascii

        

        mov rax, SYS_WRITE
        mov rsi, ascii_num
        mov rdx, [size_ascii_num]

        syscall

        mov rax, SYS_CLOSE
        pop rdi

        syscall

        jmp _end


; input rax valor
convert_dec_to_ascii:

    mov rbx, 0

    mov [ascii_num], rbx

    cmp rax, 10
    jl  _less_10

    cmp rax, 100
    jl  _less_100

    cmp rax, 199
    jg  _bigger_199

    cmp rax, 99
    jg  _bigger_99
_end


_less_10:

    add rax, 48
    mov [ascii_num], rax
    mov rax, 1
    mov [size_ascii_num], rax

    ret



_less_100:

    mov rbx, rax
    mov rcx, 10
    mov rdx, 0

    div rcx     ; rax/10

    add rax, 48
    mov [ascii_num], rax

    mov r10, ascii_num
    add r10, 1

    add rdx, 48

    mov [r10], rdx

    mov rax, 2
    mov [size_ascii_num], rax

    ret


_bigger_199:

    mov rbx, 50
    mov [ascii_num], rbx

    sub rax, 200

    mov r10, ascii_num
    add r10, 1

    mov rbx, rax
    mov rcx, 10
    mov rdx, 0

    div rcx     ; rax/10

    add rax, 48
    mov [r10], rax

    inc r10

    add rdx, 48

    mov [r10], rdx

    mov rax, 3
    mov [size_ascii_num], rax


    ret


_bigger_99:

    mov rbx, 49
    mov [ascii_num], rbx

    sub rax, 100

    mov r10, ascii_num
    add r10, 1

    mov rbx, rax
    mov rcx, 10
    mov rdx, 0

    div rcx     ; rax/10

    add rax, 48
    mov [r10], rax

    inc r10

    add rdx, 48

    mov [r10], rdx

    mov rax, 3
    mov [size_ascii_num], rax


    ret




_end:

        mov rax, SYS_EXIT
        mov rdi, 0
        syscall

