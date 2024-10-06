; This is an exercise to explore how Amstrad BASIC managed
; float numbers. The intetion here is to print a float number
; using the firmware routine that prepares the number for its
; representation (REAL_prepare_for_decimal)

org &4000


main:
    ld      hl,_float_acum
    call    &BD76       ; REAL_prepare_for_decimal in 6128 machines

    ; According to https://www.cpcwiki.eu/index.php/Programming:CPC_OS_floating_point_routines
    ; FLO_PREPARE: Prepares the display of a FLO value
    ;   Input      (HL)=float value (5 bytes in form mantissa (4) + exponent (1))
    ;   Output     (HL)=LW normed mantissa
    ;               B = sign of mantissa
    ;               D = sign of exponent
    ;               E = exponent/comma position
    ;               C = number of significant mantissa bytes (NOT digits!)
    ;    Unchanged  HL

    ; According to my notes:
    ; IX = normed mantissa LSB
    ; HL = normed mantissa MSB
    ; B  = mantissa sign: 1 possitive, 0 zero, FF negative
    ; D  = exponent sign
    ; C = 4 (mantissa total bytes)
    ; E = exponent/decimal position, 0 if zero.

    push    de

    ld      l,(ix+0)
    ld      H,(ix+1)
    ld      e,(ix+2)
    ld      d,(ix+3)

    ; DEHL holds the normed mantissa
    ; lets calculate the 9 digits diving by 10
calculate_digits:
    ld      b,9
    ld      ix,_float_conv_buffer+8
_calculate_digits_loop:
    push    bc
    call    div_DEHL_by10
    pop     bc
    add     "0"
    ld      (ix+0),a
    dec     ix
    djnz    _calculate_digits_loop
    
    pop     de

    ; In this point:
    ; D tells is if the number is possitive
    ; E tells us the position of the decimal point minus 9
    ; IX points to the last converted digit

    ld     a,d      ; A tell us now the sign: 01 + FF -
    ld     hl,text  ; address of our target text buffer
    call   float_accum2str

    ld     hl,text
    call   print_string
    call   new_line

end: jp end

 div_DEHL_by10:
   ;Inputs:
   ;     DEHL
   ;Outputs:
   ;     DEHL is the quotient
   ;     A is the remainder
   ;     BC is 10
   
    ld      bc,&0D0A
    xor     a
    ex      de,hl
    add     hl,hl
    rla
    add     hl,hl
    rla
    add     hl,hl
    rla
   
    add     hl,hl
    rla
    
    cp      c
    jr      c,$+4
    sub     c
    inc     l
    djnz    $-7
   
    ex      de,hl
    ld      b,16
   
    add     hl,hl
    rla
    cp      c
    jr      c,$+4
    sub     c
    inc     l
    djnz    $-7
    ret

; Inputs
;   A holds the decimal point position
;   HL text buffer
; Output
;   B number of written digits
;   HL next position in the text buffer
put_leading_0s:
    ld     b,0
    cp     1         ; solo 0 o <0 necesita ceros
    ret    p
    ld     (hl),"0"
    inc    hl
    ld     (hl),"."
    inc    hl
    inc    b
_put_leading_0s_loop:
    or     a
    ret    z
    ld     (hl),"0"
    inc    hl
    inc    a
    inc    b
    jr     _put_leading_0s_loop

; Inputs
;   HL target text buffer
;   A  sign (&01 possitive, &FF negative)
;   E  decimal point position
float_accum2str:
    sub    1    ; A = 0 if possitive
    jr     z,_float_leading_0s
    ld     (hl),"-"
    inc    hl
_float_leading_0s:
    ld     a,e
    add    9        ; restore decimal position
    call   put_leading_0s

    ; HL points to the text buffer next position
    ; In B we have the digits already written
_float_copy_numbers:
    ld     a,9 
    sub    b     
    ld     c,a
    ld     b,0
    ld     de,_float_conv_buffer
    ex     hl,de
    ldir
    ret     

read "print.asm"

_float_acum:
;    db  &9A, &99, &99, &19, &7F    ;0.3
;    db  &CC, &CC, &CC, &4C, &7D    ;0.1
    db  &C7, &9D, &D2, &01, &7D    ;0.06339
;    db  &00, &00, &60, &09, &8B    ;1099
;    db  &00, &00, &00, &76, &87    ;123
;    db  &00, &00, &00, &20, &83    ;5
;    db  &9A, &99, &99, &99, &7F    ;-0.3
;    db  &C7, &9D, &D2, &81, &7D    ;-0.06339
;    db  &00, &00, &60, &89, &8B    ;-1099
;    db  &00, &00, &00, &F6, &87    ;-123
;    db  &D8, &62, &B7, &4F, &79    ;0.006339
;    db  &00, &00, &00, &28, &00    ;0.0
;    db  &00, &00, &00, &00, &00    ;0
;    db  &00, &28, &6B, &6E, &9E    ;1000000000
;    db  &00, &F9, &02, &15, &A2    ;10000000000
;    db  &80, &10, &B7, &41, &A2    ;12999999999
;    db  &06, &BD, &37, &06, &6D    ;0.000001
;    db  &D6, &94, &BF, &56, &69    ;0.0000001
;    db  &12, &77, &CC, &2B, &66    ;0.00000001
;    db  &A0, &A2, &79, &6B, &9B    ;123456789
;    db  &A4, &05, &2C, &13, &9F    ;1234567890

_float_conv_buffer
    defs 10

text:
    defs 256