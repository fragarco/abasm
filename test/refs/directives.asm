; This example uses all directives listed in the ABASM manual

; Starting address, this has no effect as the test runner always 
; sets this same value for all tests.
org &1200

; code cannot go above this address
limit &C000

; aliases
equ MEM_VIDEO, &C000

; write one byte
db &FF

; align memory to multiply of 8 so we write 7 bytes as AA
align 4,&AA

; assert checking that memory position for next byte is 0x1208
assert @==&1204


; write some more data
defb "hi",&FF
defm "hi",&FF
db   "h","i",&FF
dm   "h","i",&FF

; reserve some memory
defs  4
ds    4
rmem  4

; write words
defw  100*10+24
dw    100*10+24

let ASSEMBLE=0

IF ASSEMBLE
    dw MEM_VIDEO
ELSE
    dw &FFFF
ENDIF

let ASSEMBLE=1

IF ASSEMBLE
    dw MEM_VIDEO
ELSE
    dw &FFFF
ENDIF

; Some expresions using directives to store in memory

db "L"+&80
db "L"+&40+&40
db "L"+&40*2
db "L"+(&60-&20)+(&20*2)
db "L"+&100/2

db "L"+128
db "L"+64+64
db "L"+64*2
db "L"+(128-64)+(32*2)
db "L"+256/2

; Other directives like:
; INCBIN
; READ
; REPEAT
; WHILE
; MACRO
;
; are tested by other files.