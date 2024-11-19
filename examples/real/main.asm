; This is an exercise to explore how Amstrad BASIC managed
; float numbers. The intetion here is to print a float number
; using the firmware routine that prepares the number for its
; representation (REAL_prepare_for_decimal)

org &4000

num_start equ 00     ; Range of 0 to 24
num_end   equ 25    ; Range of num_start to 25

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
    ld      l,(ix+0) ; Copy to DEHL the normed mantissa
    ld      H,(ix+1) 
    ld      e,(ix+2) 
    ld      d,(ix+3)
    ld      b,9      ; lets calculate the actual digits diving by 10 9 times
    ld      c,9      ; lets store in C the significant digits (no trailing 0s)
    ld      ix,_float_conv_buffer+8 ; digits are stored here from back to front

_calculate_digits_loop:
    push    bc
    call    div_DEHL_by10
    pop     bc
    bit     7,c     ; check MSb, are we still removing traling 0?
    jr      nz,_calculate_digits_next
    or      a       ; is this a 0?
    jr      nz,_calculate_digits_not0
    dec     c
    jr      _calculate_digits_next
_calculate_digits_not0:
    set     7,c     ; set MSb to 1 so we don't look for more trailing 0s
_calculate_digits_next:
    add     "0"
    ld      (ix+0),a
    dec     ix
    djnz    _calculate_digits_loop
    res     7,c    ; leave in C just the number of significant digits
    pop     de

    ; At this point:
    ; D tells if the number is possitive
    ; C has the significant number of digits (9 - trailing 0s)
    ; E is the position of the decimal point minus 9
    ; IX points to the last converted digit
    ld     hl,text  ; address of our target text buffer
    ld     a,d      ; A is now the sign: 01 for + and FF for -
    sub    1        ; A = 0 if possitive
    jr     z,_float_check_exp
    ld     (hl),"-" ; Lets write the negative sign
    inc    hl

_float_check_exp:
    ld     b,0      ; total number of written digits
    ld     ix,_float_conv_buffer+5 ; position for E notation
    ld     a,e
    add    9        ; restore decimal position
    cp     &80      ; EXP > 0? is a big number else small one
    jr     c,_float_check_exp_big
    push   af
    sub    c        ; check if decimal position plus digits is too much
    cp     &F8
    jr     c,_float_write_exp_small
    pop    af
    jr     _float_check_exp_end
_float_write_exp_small:
    pop    af
    ld     (ix+0),"E"
    ld     (ix+1),"-"
    ld     (ix+2),"X"
    ld     (ix+3),"X"
    ld     a,1
    ld     c,1
    jr     _float_copy_numbers
_float_check_exp_big:
    cp     10        ; EXP > 10? then we need E notation
    jr     c,_float_check_exp_end
    ld     (ix+0),"E"
    ld     (ix+1),"+"
    ld     (ix+2),"X"
    ld     (ix+3),"X"
    ld     a,1      ; new decimal position
    ld     c,1
    jr     _float_copy_numbers
_float_check_exp_end:
    ld     c,a      ; keep in C the decimal position + 9
    

    ; At this point
    ; A and C hold the decimal point position
    ; B number of current written digits
    ; HL text buffer
_float_write_numbers:
    cp     1        ; only if A <=0 we need leading 0s
    jp     p,_float_copy_numbers
    ld     (hl),"0"
    inc    hl
    ld     (hl),"." 
    inc    hl
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
    dec    b
    jr     z,_float_remove_trailing_0s
    dec    c
    jr     nz,_float_copy_numbers_loop
    ld     (hl),"."    ; add . in the correct position
    inc    hl          ; if number is >0
    jr     _float_copy_numbers_loop

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
    db  &14, &52, &06, &1E, &81    ;1.23456789
    db  &BA, &E9, &D6, &7C, &7D    ;0.123456789
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
    db  &CF, &FE, &E6, &5B, &5F    ;0.0000000001
    db  &1D, &C6, &BF, &4F, &79    ;0.0063399999

_float_conv_buffer
    defs 10

text:
    defs 256