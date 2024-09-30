FW_PRINT_CHAR equ &BB5A

new_line:
    ld a, 13
    call FW_PRINT_CHAR
    ld a, 10
    jp FW_PRINT_CHAR
    ret
    
print_string:
    ld a, (hl)
    cp &FF
    ret z
    inc hl
    call FW_PRINT_CHAR
    jr print_string
