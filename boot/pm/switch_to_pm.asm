[bits 16]
; Switch to protected mode
switch_to_pm:
    cli                     ; Turn off interrupts until protected mode
                            ; interrupt vectors are set-up
    
    lgdt [gdt_descriptor]   ; Load the GDT which defines the protected
                            ; mode segments (for code and data)

    mov eax, cr0            ; Copy CR0 (control register) to EAX
    or eax, 0x1             ; to set the first bit
    mov cr0, eax            ; and set back into CR0

    jmp CODE_SEG:init_pm    ; Make a far jump (to a new segment) to
                            ; the 32-bit code, which will also force
                            ; the CPU to flush its cache of
                            ; potentially 16-bit instructions

[bits 32]
; Initialise registers and the stack once in PM
init_pm:
    mov ax, DATA_SEG        ; In PM, old segments are meaningless,
    mov ds, ax              ; so we point all segment registers to
    mov ss, ax              ; the data selector defined in the GDT
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; Update the stack position so it is right
    mov esp, ebp            ; at the top of the free space

    call BEGIN_PM           ; Call the label beginning PM code