OUT_CHAR equ &BB5A    ; Amstrad Firmware routine for char printing

; Main entry point. Make file will search for this symbol and
; set its address as the starting point for the program.

org &1200

main:
    ld   hl, message
    call print_string
    call new_line
loop:
    jp   loop

message: db "Hello world!",0
 
print_string:
    ld   a,(hl)
    or   a
    ret  z
    inc  hl
    call OUT_CHAR
    jr   print_string

new_line:
    ld   a,13
    call OUT_CHAR
    ld   a,10
    jp   OUT_CHAR
