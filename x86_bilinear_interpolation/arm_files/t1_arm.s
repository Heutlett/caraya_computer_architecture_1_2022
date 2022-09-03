.text
.global _start
// Valores iniciales
_start: 
mov r1, #0x41           // Seed = NumActual = A = 65D = 0x41 (Adrian) 
str r1, [sp]         	// Se guarda la semilla en sp
mov r2, #0              // Contador
mov r3, #0x4          // Resultado
mov r0, #10             // N (Cantidad de numeros aleatorios por generar)

// Ciclo LFSR
_lfsr:
    
     // Condicional

    cmp r2, r0          // Contador == N
    beq _end             // Si Contador == 100, salta a end
    
    // Calculo del numero aleatorio

    mov r5, r1, LSR #2  // NumActual >> 2:  [x^1 x^2 x^3 x^4 x^5 (x^6) x^7 x^8]
    and r6, r5, #1      // NumActual & 1 = x^6    (Mascara)

    mov r5, r1, LSR #3  // NumActual >> 3:  [x^1 x^2 x^3 x^4 (x^5) x^6 x^7 x^8] 
    and r5, r5, #1      // (NumActual >> 2) & 1 = x^5    (Mascara)


    eor r7, r6, r5      // x^6 xor x^5
    and r7, r7, #1      // Feedback = (x^6 xor x^5) & 1    (Mascara)
    
    mov r4, r1, LSR #1  // NumActual >> 1    (Rotacion a la derecha)
    mov r8, r7, LSL #7  // Feedback << 7    
    orr r1, r4, r8      // NumActual = NumActual | Feedback    (MSB = Feedback)
    
    // Actualizacion de registros

    mov r8, r2, LSL #2  // Contador << 2 (Incremento de +4 para la direccion de memoria del resultado)
    add r8, r8, r3      // Direccion del resultado = 0x100 + Contador+4
    str r1, [sp,r8]     // Resultado[Contador] = NumActual
    
    // Siguiente iteracion

    add r2, r2, #1      // Contador++
    b _lfsr               
    
_end:
mov r7, #1
swi 0
