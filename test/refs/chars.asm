; This program prints all ASCII characters between code 32 and 128.
; It's a variation of the first example presented in the MAXAM manual

.main                ; defines a global label
    ld a,32          ; first ASCII code in accumulator

.loop                ; Defines a label 'loop'
    call &BB5A       ; CALL txt_output, the firmware output routine
    inc  a           ; move to next character
    cp   128         ; have we done them all?
    jr   c,loop      ; no - go back for another one

.end  
    jp   end         ; infinite loop used as the program's end point

