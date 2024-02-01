; Ensures that the kernel is entered from its start() function
[bits 32]           ; Running in 32-bit protected mode
[extern _start]     ; Declare external symbol _start
call _start         ; Call the start() function
jmp $               ; Hang forever when return from the kernel