// After system call, register r0 contains the return value of the system call. 


.data 
.balign 4
ruta_archivo: .asciz "imagen.txt" 

.text
.global _start
_start: 

    ldr r0, =ruta_archivo       // arg0 (%r0): Ruta del archivo
    mov r1, #00000              // arg1 (%r1): flags

    mov r7, #5
    swi #0                      // Llamada al sistema:   abre el archivo

_leido:

    mov r1, r0
    ldr r0, =resultado
    mov r2, #1                  // nbytes a leer

    mov r7, #3                  // Leer el archivo
    swi #0                      // Llamada al sistema

_escribir:

    mov r7, #6                  // Cerrar el archivo
    swi #0                      // Llamada al sistema

_end:

mov r7, #1
swi 0
