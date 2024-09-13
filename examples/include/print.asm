FW_PRINT_CHAR equ &BB5A

new_line:
    ld a, 13
    call print_char
    ld a, 10
    jp print_char
    ret
    
print_string:
    ld a, (hl)
    cp &FF
    ret z
    inc hl
    call FW_PRINT_CHAR
    jr print_string
