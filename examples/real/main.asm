org &4000   ; sin esto falla la carga desde la consola de RVM

; Notas sobre REAL_prepare_for_decimal
;
; HL = direccion del numero en coma flotante
; primero llama a REAL_SIGN lo que pasa HL a IX 
; devuelve la comparacion en A:
;    A=1,NZ,NC  si num > 0
;    A=0,Z,NC   si num == 0
;    A=&FF,NZ,C si num < 0

; mediante sbc a,a  pasa el flag de CARRY al registro A
; asi sabe la rutina si el exp es <0 o >0 (pues lo hace tras restar 0x80)
; tras eso, D = C y E = exp - 0x80, basicamente mete el
; exponente en un word y usa C para propagar el signo, con lo que el
; exponente sin bias queda guadado en DE y en HL de cara a multiplicar.
; Al acabar de multiplicar para calcular el exponente en base 10,
; resta -9 que es el numero total de espacios para decimales
; y lo almacena en D. C termina valiendo el numero de bytes que usa
; el numero (4 para el caso de reales)

main:
    ld      hl,numero
    call    &BD76       ; REAL_prepare_for_decimal

; En este punto IX = LSB
; HL = MSB
; B = signo de la mantisa: 1 si positivo, 0 si cero, FF si negativo
; D = signo del exponente
; C = 4 (bytes significativos de la mantisa, los reales suelen ocupar 4 bytes)
; E = posicion del exponente/coma decimal o 0 si num = 0.

    push    de
    pop     iy
    ld      l,(ix+0)
    ld      H,(ix+1)
    ld      e,(ix+2)
    ld      d,(ix+3)
    ld      b,&09

calculate_digits:
    push    bc
    call    div_DEHL_by10
    pop     bc
    push    af
    djnz    calculate_digits
    
    push    iy
    pop     de

    ; En este punto tenemos en DE si es positivo y el numero de digitos totales
    ; En la pila tenemos los digitios de izquerda a derecha

    ld     hl,text  ; ponemos la direccion del buffer de texto
    ld     a,d      ; en A cargamos el signo: 01 + FF -
    call   float_stack2mem

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

; En A tenemos el signo (&FF o &01)
; En HL tenemos el inicio del buffer de texto
put_sign_char:
    sub    1    ; A = 0 si es positivo
    ret    z
    ld     (hl),"-"
    inc    hl
    ret

; En A tenemos la posicion de la coma decimal
; En HL el comiendo del buffer de texto
; Devolvemos en B los caracteres escritos
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

float_stack2mem:
    call   put_sign_char

    ld     a,e
    add    9        ; aqui tenemos la posicion de la coma decimal
    call   put_leading_0s

    ; En HL tenemos el buffer de texto
    ; En B tenemos los digitos ya escritos
    pop    ix    ; retorno de la rutina
_float_pop_numbers:
    ld     a,9   ; hay que sacar los 9 digitos del stack
    sub    b     ; quitamos los digitos ya escritos
    ld     b,a
    ld     c,9   ; maximo numero de digitos
_float_pop_numbers_loop:
    pop    de
    ld     a,b
    or     a
    jr     nz,_float_pop_number_store
_float_pop_numbers_checkend:
    dec    c
    jr     nz, _float_pop_numbers_loop
    push   ix    ; restauramos valor de retorno
    ret     
_float_pop_number_store:
    ld     a,d
    add    "0"
    ld     (hl),a
    inc    hl
    dec    b
    jr     _float_pop_numbers_checkend

read "print.asm"

numero:
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
separator:
    db  &FF, &FF, &FF, &FF, &FF
text:
    defs 256