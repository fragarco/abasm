.module tilemap

.include "TileMap.s"


.globl _cpc_PutSpTileMap

_cpc_PutSpTileMap::


    ex de,hl

;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer

push ix
call rutina

pop ix
ret


; APROVECHAR ESTA RUTINA PARA CALCULAR POSICION EN SUPERBUFFER EN FUNCION DE NUEVA POSICION (CALCULO RELATIVO)

rutina:
    .db #0xdd
    ld l,e                                        ;2
    .db #0xdd
    ld h,d                                        ;2
                                                ; --> 15 NOPS

;Obtencion de dimensiones, solo usadas para calcular iteraciones -> BC

ld l,0 (ix)
ld h,1 (ix)        ;dimensiones del sprite
ld C,(hl) 
inc hl
ld B,(hl) 
Dec b
Dec c
;->BC coord -1

    ld l,10 (ix)
    ld h,11 (ix)    ;recoje coordenadas anteriores

    ld e,8 (ix)
    ld d,9 (ix)		;recoje coordenadas actuales
	
    ld 10 (ix),e
    ld 11 (ix),d	;actualiza coordenadas anteriores con las actuales


;Obtencion x0y0 -> HL
PUSH HL
Srl l  ; x0/2
Srl h
Srl h
Srl h ; y0/8
ld a,h
ld (#bucle_pasos_anchoW+1),a

;ld a,l
;ld (#bucle_pasos_anchoW-1),a

Ex de,hl  ;-> Guarda de con origen de loops

POP hl ;(recuperar coord xoyo)
Add hl,bc  ;(Suma de dimensiones)
Srl l ; (x0+ancho)/2
Srl h
Srl h
Srl h; (y0+alto)/2

xor a
SBC hl,de        ;diferencia entre bloque inicial y bloque con dimensiones

;Hl tiene iteraciones en i,j partiendo de origen loops
Ld a,h
Inc a
Ld (pasos_alto_xW+1),a
;Ld a,l
;Inc a
inc l




pasos_ancho_xW:    ; *parametro
    ;ld b,a
	ld b,l

	;ld e, #0x00
	bucle_pasos_anchoW:
    ;push de
	ld d, #0x00
pasos_alto_xW: ; *parametro
    ld c,#0
bucle_pasos_altoW:
        ; Mete E y D
            call _cpc_UpdTileTable		;corrompe HL y A
        inc d
        dec c
        jp nz,bucle_pasos_altoW

   ;pop de
    inc e
    dec b
    jp nz,bucle_pasos_anchoW

    ret
