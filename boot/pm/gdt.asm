; Global Descriptor Table
gdt_start:

gdt_null:               ; Mandatory null descriptor (8 zero bytes)
    dd 0x0              ; Double word (4 zero bytes)
    dd 0x0              ; Double word (4 zero bytes)

gdt_code:               ; Code segment descriptor
    ; Base = 0x0, Limit = 0xfffff,
    ; 1st Flags: (present) 1 | (privilege) 00 | (descriptor type) 1 -> 1001b
    ; Type Flags: (code) 1 | (conforming) 0 | (readable) 1 | (accessed) 0 -> 1010b
    ; 2nd Flags: (granularity) 1 | (32-bit default) 1 | (64-bit seg) 0 | (AVL) 0 -> 1100b
    dw 0xffff           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10011010b        ; 1st flags, type flags
    db 11001111b        ; 2nd flags, Limit (bits 16-19)
    db 0x0              ; Base (bits 24-31)

gdt_data:               ; Data segment descriptor
    ; Same setup as code segment except for type flags
    ; Type Flags: (code) 0 | (expand down) 0 | (writable) 1 | (accessed) 0 -> 0010b
    dw 0xffff           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10010010b        ; 1st flags, type flags
    db 11001111b        ; 2nd flags, Limit (bits 16-19)
    db 0x0              ; Base (bits 24-31)

gdt_end:                ; Label at the end for the assembler to calculate
                        ; the size of the GDT for GDT descriptor

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; Size of GDT minus one
    dd gdt_start                    ; Start address of the GDT

; Define constants for the GDT descriptor offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
