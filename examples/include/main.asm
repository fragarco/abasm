; Incliding another ASM file example
; This code builds upon the Hello World example
; using the directive read to import code from 
; another ASM file.

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; BASM call
;
; org &1200

main:
    ld hl, message
    call print_string
    call new_line
loop:
    jp loop

message: db "Hello World!", 255

read "print.asm"

