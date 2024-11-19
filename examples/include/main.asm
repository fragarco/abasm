; Including another ASM file example
; This code builds upon the Hello World example
; using the directive READ to import code from 
; another ASM file.

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; ABASM call
;
; org &1200

main:
    ld hl, message
    call print_string
    call new_line
loop:
    jp loop

read "print.asm"

message: db "Hello World!", &FF



