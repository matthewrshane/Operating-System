; Prints a hex string
; Params: dx - the value to print
print_hex:
    pusha                   ; Push all registers onto the stack
    mov bx, HEX_OUT + 5     ; set bx to HEX_OUT + 5
    mov ax, 0               ; zero ax
    mov al, dl              ; set al = dl (lower half of dx)
    mov cl, 16              ; set cl = 16
    div cl                  ; divide ax by 16 (cl), quotient -> al, remainder -> ah
    mov [bx], ah            ; set [bx] to ah
    dec bx                  ; dec bx
    mov [bx], al            ; set [bx] to al
    dec bx                  ; dec bx
    mov ax, 0               ; zero ax
    mov al, dh              ; set al = dh (high half of dx)
    div cl                  ; divide ax by 16 (cl), quotient -> al, remainder -> ah
    mov [bx], ah            ; set [bx] to ah
    dec bx                  ; dec bx
    mov [bx], al            ; set [bx] to al
    print_hex_loop:         ; label for loop
    mov al, [bx]            ; set al = [bx]
    cmp al, 10              ; compare al with 10
    jl print_hex_2          ; jump if less than (0-9)
    add al, 55              ; otherwise (A-F), add 55 to al
    jmp print_hex_3         ; jump over section for 0-9
    print_hex_2:            ; label for 0-9
    add al, 48              ; add 48 to al (ascii 0-9)
    print_hex_3:            ; label to jump to
    mov [bx], al            ; set [bx] = al
    inc bx                  ; increment bx
    cmp bx, HEX_OUT + 5     ; compare bx to HEX_OUT + 5
    jle print_hex_loop      ; jump if less than or equal to back up to the loop
    mov bx, HEX_OUT         ; set bx to HEX_OUT
    call print_string       ; call print_string
    popa                    ; Pop all registers off the stack
    ret                     ; Return to the program

; Variables
HEX_OUT:
    db "0x0000",0