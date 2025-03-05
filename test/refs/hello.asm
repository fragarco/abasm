; Hello World example
; A modified version from http://www.chibiakumas.com/z80/helloworld.php
; A good resource for tutorials regarding the assembly programming of the Z80

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; ABASM call
;
; org &1200

print_char equ &BB5A    ; Amstrad Firmware routine for char printing

main:
    ld hl, message
    call print_string
    call new_line
loop:
    jp loop

message: db "Hello world!",&FF

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
    call print_char
    jr print_string
