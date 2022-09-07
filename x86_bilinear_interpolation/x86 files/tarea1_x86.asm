section .data
    array TIMES 11 db 0b    ; Arreglo de resultados
                            ; Son 11 espacios para guardar primero la seed
                            ; y luego los 10 randoms generados

section .text

	global _start
	
	_start:

        mov r11d,array      ; Guarda en r11d el puntero al array

        mov ebx,65          ; Seed

        mov [r11d], ebx     ; Guarda la seed en la primera posicion del array 
        
        inc r11d            ; Se mueve el puntero

        mov r8d,ebx
        
        mov ecx,0           ; Contador

        mov edx,10          ; N

        int 80h

    _lfsr:

        ;Condicional

        cmp ecx, edx        ; Contador == N

        je _end             ; Si Contador == 100, salta a end

        ;Calculo del numero aleatorio

    _step1:

        shr r8d, 2          ; NumActual >> 2:  [x^1 x^2 x^3 x^4 x^5 (x^6) x^7 x^8]
        and r8d, 1          ; NumActual & 1 = x^6    (Mascara)
        mov r9d, r8d

    _step2:

        mov r8d, ebx
        shr r8d, 3          ; NumActual >> 3:  [x^1 x^2 x^3 x^4 (x^5) x^6 x^7 x^8] 
        and r8d, 1          ; (NumActual >> 2) & 1 = x^5    (Mascara)
        mov r10d, r8d

    _step3:

        xor r9d,r10d        ; x^6 xor x^5
        mov r8d, r9d
        and r8d, 1          ; Feedback = (x^6 xor x^5) & 1    (Mascara)

    _step4:

        mov r9d, ebx        
        shr r9d, 1          ; NumActual >> 1    (Shift a la derecha)

    _step5:

        shl r8d, 7          ; Feedback << 7    
        or  r8d,r9d         ; NumActual = NumActual | Feedback    (MSB = Feedback)
        mov ebx, r8d

        mov [r11d], ebx     ; Se guarda el valor obtenido en el array

        inc r11d            ; Se mueve el puntero

        ;Actualizacion de registros

        add ecx,1           ; Se aumenta el contador

        jmp _lfsr

        int 80h


    _end:

        mov eax,1           ; Pone el valor 1 en registro eax
                            ; para hacer la llamada a la funcion exit (sys_exit) 

        mov ebx,0           ; Pone el valor 0 en el registro ebx
                            ; para indicar el codigo de retorno (0=sin errores)

        int 80h             ; Llama al sistema operativo