; This is an exercise to explore how Amstrad BASIC managed
; float numbers. The intetion here is to print a float number
; using the firmware routine that prepares the number for its
; representation (REAL_prepare_for_decimal)

org &4000

num_start equ 0     ; Range of 0 to 21
num_end   equ 22    ; Range of num_start to 22

main:
    ld      hl,_float_acum + (num_start * 5)
    ld      b, num_end - num_start  ; how many numbers to convert and print
main_loop:
    push    bc
    push    hl
    call    float_conv_bin2str

print_result:
    ld     hl,text
    call   print_string
    call   new_line

    pop    hl
    inc    hl
    inc    hl
    inc    hl
    inc    hl
    inc    hl 
    pop    bc
    djnz   main_loop

end: jp end

; Inputs
;   HL pointer to the float acumulator where the float number is
;  Outputs
;   leaves the converted string in the 'text' buffer
float_conv_bin2str:
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
    ld      a,b
    cp      0
    jr      nz, _calculate_digits
    
    ; The number is 0
    ld      hl,text
    ld      (hl), "0"
    inc     hl
    ld      (hl), &00
    ret

_calculate_digits:
    push    de
    ld      l,(ix+0) ; DEHL holds the normed mantissa
    ld      H,(ix+1) 
    ld      e,(ix+2) 
    ld      d,(ix+3)
    ld      b,9      ; lets calculate the 9 digits diving by 10
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

    ; At this point:
    ; D tells if the number is possitive
    ; E is the position of the decimal point minus 9
    ; IX points to the last converted digit
    ld     hl,text  ; address of our target text buffer
    ld     a,d      ; A is now the sign: 01 + FF -
    sub    1        ; A = 0 if possitive
    jr     z,_float_leading_0s
    ld     (hl),"-" ; Lets write the negative sign
    inc    hl

_float_leading_0s:
    ld     a,e
    add    9        ; restore decimal position
    ld     c,a      ; keep in C the decimal position + 9
    ; At this point
    ; A and C hold the decimal point position
    ; HL text buffer
    ld     b,0       ; total number of written digits
    cp     1         ; only if A <=0 we need leading 0s
    jp     p,_float_copy_numbers
    ld     (hl),"0"
    inc    hl
    ld     (hl),"."
    inc    hl
    inc    b
_put_leading_0s_loop:
    or     a
    jr     z,_float_copy_numbers
    ld     (hl),"0"
    inc    hl
    inc    a
    inc    b
    jr     _put_leading_0s_loop

    ; HL points to the text buffer next position
    ; In B we have the digits already written
    ; In C we have the decimal position
_float_copy_numbers:
    ld     de,_float_conv_buffer
    ld     a,9 
    sub    b     
    ld     b,a      ; B = max number of digits that we can still print
_float_copy_numbers_loop:
    ld     a,(de)
    ld     (hl),a
    inc    hl
    inc    de
    dec    c
    jr     nz, _float_copy_numbers_loop01
    ld     (hl),"."    ; add . in the correct position
    inc    hl          ; if number is >0
_float_copy_numbers_loop01:
    djnz   _float_copy_numbers_loop
    ; At this point
    ; C contains again original decimal point position (biased -9)
    ; HL points to the end of text buffer
_float_remove_trailing_0s:
    bit    7,c      ; if A is negative we remove trailing 0s
    ret    z        ; no traling 0s
    dec    hl       ; point to the last digit
_float_remove_trailing_loop:
    ld     a,(hl)
    cp     "0"
    jr     z,_float_remove_trailing_char
    cp     "."
    jr     z,_float_remove_trailing_char
    ret    
_float_remove_trailing_char:
    ld     (hl), &00
    dec    hl
    jr     _float_remove_trailing_loop

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

read "print.asm"

_float_acum:
    db  &00, &00, &00, &28, &00    ;0.0
    db  &CC, &CC, &CC, &4C, &7D    ;0.1
    db  &9A, &99, &99, &19, &7F    ;0.3
    db  &C7, &9D, &D2, &01, &7D    ;0.06339
    db  &D8, &62, &B7, &4F, &79    ;0.006339
    db  &9A, &99, &99, &99, &7F    ;-0.3
    db  &C7, &9D, &D2, &81, &7D    ;-0.06339
    db  &06, &BD, &37, &06, &6D    ;0.000001
    db  &D6, &94, &BF, &56, &69    ;0.0000001
    db  &12, &77, &CC, &2B, &66    ;0.00000001
    db  &00, &00, &00, &00, &00    ;0
    db  &00, &00, &00, &20, &83    ;5
    db  &00, &00, &00, &76, &87    ;123
    db  &00, &00, &60, &09, &8B    ;1099
    db  &DD, &24, &52, &1A, &8B    ;1234.567
    db  &00, &00, &00, &F6, &87    ;-123
    db  &00, &00, &60, &89, &8B    ;-1099
    db  &A0, &A2, &79, &6B, &9B    ;123456789
    db  &A4, &05, &2C, &13, &9F    ;1234567890
    db  &00, &28, &6B, &6E, &9E    ;1000000000
    db  &00, &F9, &02, &15, &A2    ;10000000000
    db  &80, &10, &B7, &41, &A2    ;12999999999

_float_conv_buffer
    defs 10

text:
    defs 256