; Prints a single character
; Params: ch - the character to print
print_char:
    pusha
    mov al, ch
    mov ah, 0x0E
    int 0x10
    popa
    ret

; Prints a string of characters
; Params: bx - first memory location of a null terminated string
print_string:
    pusha                   ; Push all registers onto the stack
    print_string_loop:      ; Create a loop label
    mov al, [bx]            ; Read char at mem addr bx into al
    cmp al, 0               ; Compare al to 0
    je print_string_end     ; If equal, jump to end of function
    mov ah, 0x0E            ; Set ah to the print interrupt vector
    int 0x10                ; Call the print interrupt
    add bx, 1               ; Add 1 to bx to get the next char
    jmp print_string_loop   ; Loop back to start
    print_string_end:       ; Create a end label
    popa                    ; Pop all registers back from the stack
    ret                     ; Return from the function