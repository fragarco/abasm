; ABASM expression evaluation test
;

MEM_VIDEO   equ &C000
FIVE        equ 5
TEN         equ 10
MASK        equ &F0
LOWNIB      equ &0F
THIRTY      equ 16*8/4+8

start:
    db 16*8                 ; 128
    db 3+4*5                ; 23  (Python precedence, as warned in the manual)
    db (3+4)*5              ; 35
    db 100-42               ; 58
    db -5                   ; 251 (two's complement)
    db -128                 ; 128
    db +7                   ; 7
    db FIVE+TEN             ; 15
    db THIRTY-8             ; 32
    db 10/3                 ; 3   (integer division)
    db 7/2                  ; 3
    db 10 MOD 3             ; 1

    db &3F AND &C0          ; 0
    db &F3 AND MASK         ; 240
    db MASK | LOWNIB        ; 255
    db 3 OR 4               ; 7
    db 5 XOR 3              ; 6
    db MASK ^ &FF           ; 15
    db 1 << 4               ; 16
    db 256 >> 2             ; 64
    db ~0                   ; 255

    db &0A                  ; 10  (hex)
    db #0B                  ; 11  (hex)
    db %1010                ; 10  (binary)
    db 0x0C                 ; 12  (hex)
    db 0B1011               ; 11  (capitalized binary)
    db 0040                 ; 40  (leading zeros are decimal, not octal)
    db "A"                  ; 65  (character literal)
    db "L"+&80              ; 204
    db "A"-"a"+&100         ; 224
    db "0"+10               ; 58

    db $ AND 255            ; low byte of the current address
    db @ AND 255            ; same value as $
    db ($+1) AND 255        ; location counter plus one
    dw $
    dw MEM_VIDEO+100*2

    db fwd AND 255          ; low byte of a label defined after the point of use
    dw fwd                  ; full forward label in a word
    dw fwd2                 ; second forward label
    ld hl, fwd2             ; forward label in an instruction
    jp fwd2                 ; forward label in a jump

; --- Comparisons used by the IF family ---
if FIVE = 5                 ; single '=' accepted by WinAPE compatibility
    db &AA
endif
if FIVE == 5
    db &BB
endif
if FIVE != 6
    db &CC
endif
if 3 < 4
    db &DD
endif
if 4 <= 4
    db &EE
endif
if 5 > 4
    db &FF
endif
if 5 >= 5
    db &11
endif
ifnot FIVE == 6
    db &22
endif
if 1 = 0
    db &99                  ; must not be emitted
elseif FIVE == 5
    db &33
else
    db &98                  ; must not be emitted
endif
if TEN - FIVE * 2 = 0
    db &44
endif

let n=1                     ; LET symbols in expressions
let n=n+1
let n=n*20
    db n                    ; 40
    assert n == 40
    assert (MASK | LOWNIB) == &FF

let i=0                     ; WHILE loop driven by an expression
    while i < 3
    db &B0+i
    let i=i+1
    wend

    repeat 3                ; REPEAT loops
    db &C1
    rend
    repeat FIVE-2
    db &C2
    rend

macro emit2 _X_             ; Macros with expressions in the parameters and the body
    db _X_*2
    db (_X_+1)*3
endm
    emit2 3                 ; 6, 12

end:
fwd:
    db &00                  ; target of the forward 'db fwd' above
fwd2:
    nop

    print "total bytes:", end-start
