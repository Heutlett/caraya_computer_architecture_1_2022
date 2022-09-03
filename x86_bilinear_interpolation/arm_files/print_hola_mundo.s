.global  _start
  _start:
        mov R7, #4      // Syscall number
        mov R0, #1      // Stdout is monitor
        mov R2, #14     // String is 14 chars long
        ldr R1,=string  // String located at string
        swi 0
        mov R7, #1      // exit syscall
        swi 0
.data
  string:
        .ascii "Hello, World!\n"

  buffer: 
        
