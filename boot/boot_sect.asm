; A boot sector that enters 32-bit protected mode
[org 0x7C00]                ; Tell the assembler where the code is located
KERNEL_OFFSET equ 0x1000    ; Memory offset where to load the kernel

    mov [BOOT_DRIVE], dl    ; BIOS stores boot drive in dl, save for later

    mov bp, 0x9000          ; Set stack base
    mov sp, bp              ; Set stack size = 0

    mov bx, MSG_REAL_MODE   ; Load 16-bit real mode message
    call print_string       ; Print the message using BIOS

    call load_kernel        ; Load the kernel

    call switch_to_pm       ; Note that this never returns

    jmp $                   ; Loop forever

; Includes
%include "boot/print/print_string.asm"      ; 16-bit BIOS print
%include "boot/disk/disk_load.asm"          ; Load sectors from disk
%include "boot/pm/gdt.asm"                  ; Global Descriptor Table
%include "boot/pm/print_string_pm.asm"      ; 32-bit PM print
%include "boot/pm/switch_to_pm.asm"         ; Switch to PM code

[bits 16]
; Load the kernel
load_kernel:
    mov bx, MSG_LOAD_KERNEL ; Print kernel loading message
    call print_string       ; Call 16-bit BIOS print
    
    mov bx, KERNEL_OFFSET   ; Set up params for disk_load routine,
    mov dh, 15              ; with 15 sectors being loaded from
    mov dl, [BOOT_DRIVE]    ; [BOOT_DRIVE] disk
    call disk_load          ; Then call the routine

    ret                     ; Return from the routine

[bits 32]
; This is where we arrive after switching to and initialising PM
BEGIN_PM:
    mov ebx, MSG_PROT_MODE  ; Load 32-bit switch message
    call print_string_pm    ; Print using 32-bit PM print routine

    call KERNEL_OFFSET      ; Jump to the address of our loaded
                            ; kernel code

    jmp $                   ; Hang CPU

; Global variables
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Started in 16-bit Real Mode",0
MSG_PROT_MODE   db "Successfully landed in 32-bit Protected Mode",0
MSG_LOAD_KERNEL db "Loading kernel into memory...",0

; Padding and magic number
times 510-($-$$) db 0
dw 0xAA55