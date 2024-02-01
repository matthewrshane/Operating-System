[bits 32]

; Define constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

; Prints a null-terminated string
; Params: EBX - memory address of the string
print_string_pm:
    pusha                       ; Push all registers onto the stack
    mov edx, VIDEO_MEMORY       ; Set edx = the first addr of video memory

print_string_pm_loop:
    mov al, [ebx]               ; Store the ASCII char code at EBX into AL
    mov ah, WHITE_ON_BLACK      ; Set attributes of the character

    cmp al, 0                   ; If al == 0, reached the end of the string
    je print_string_pm_done     ; Jump to done

    mov [edx], ax               ; Store char and attributes at current char cell
    add ebx, 1                  ; Increment EBX to the next char in string
    add edx, 2                  ; Move to next char cell in memory

    jmp print_string_pm_loop    ; Loop back to print the next char

print_string_pm_done:
    popa                        ; Pop all registers off the stack
    ret                         ; Return from the function