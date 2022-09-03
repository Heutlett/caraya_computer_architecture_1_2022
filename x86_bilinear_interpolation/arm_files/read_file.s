// After system call, register r0 contains the return value of the system call. 


.data 
.balign 4
ruta_archivo:   .ascii "imagen.txt" 
buffer:         .skip       400

.text
.global _start
_start: 

    ldr r0, =ruta_archivo       // arg0 (%r0): Ruta del archivo
    mov r1, #00000              // arg1 (%r1): flags

    mov r7, #5
    swi #0                      // Llamada al sistema:   abre el archivo

_leido:

    mov r1, r0                  // char *buf
    ldr r0, =buffer             // unsigned int fd
_prueba1:
    lsl r0,r0, #2
_prueba:
    mov r2, #4                  // nbytes a leer

    mov r7, #3                  // Leer el archivo
    swi #0                      // Llamada al sistema

_escribir:


    mov R7, #4                  // Syscall number
    mov R0, #1                  // Stdout is monitor
    mov R2, #4                  // String is 14 chars long
    ldr R1,=buffer              // String located at string
    swi 0


_cierra:

    mov r7, #6                  // Cerrar el archivo
    swi #0                      // Llamada al sistema

_end:

mov r7, #1
swi 0
