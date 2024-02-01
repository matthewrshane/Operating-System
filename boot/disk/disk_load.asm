; Load DH sectors to ES:BX from drive DL
; Params: DH - # of sectors
;         ES - segment register
;         BX - memory location to be used with ES
;         DL - drive number
disk_load:
    push dx         ; Store DX on stack so it can be recalled later,
                    ; we want to know the expected # of sectors to
                    ; check for errors
    mov ah, 0x02    ; BIOS read sector function
    mov al, dh      ; Read DH # of sectors
    mov ch, 0x00    ; Select cylinder 0
    mov dh, 0x00    ; Select head 0
    mov cl, 0x02    ; Start reading from the second sector (after boot
                    ; sector)
    int 0x13        ; BIOS interrupt

    jc disk_error   ; Jump if error occurs (carry flag set)

    pop dx          ; Restore DX from stack
    cmp dh, al      ; If AL (sectors read) != DH (sectors expected)
    jne disk_error  ; Display error message
    ret             ; Return to the program

; Send the user a message if there was a disk error
disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    jmp $

; Variables
DISK_ERROR_MSG:
    db "Disk read error!",0
