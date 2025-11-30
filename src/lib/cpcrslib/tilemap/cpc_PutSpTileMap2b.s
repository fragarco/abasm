.module tilemap

.include "TileMap.s"
.include "TileMapC.h"


.globl _cpc_PutSpTileMap2b

_cpc_PutSpTileMap2b::

    ex de,hl

;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer

push ix
call rutina

pop ix
ret

rutina:
	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS



  ;lo cambio para la rutina de multiplicar
    ld a,8 (ix)
    ld e,9 (ix)


;.include "multiplication1.s"



		LD	  HL,#ancho_pantalla_bytes*256       
        LD    D, L
        LD    B, #8

MULT2:   ADD   HL, HL
        JR    NC, NOADD2
        ADD   HL, DE
NOADD2:  DJNZ  MULT2





	;ld b,#0
	ld e,a
	add hl,de
	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)


	ld 4 (ix),l		;update superbuffer address
    ld 5 (ix),h


	ld e,0 (ix)
    ld d,1 (ix)	;HL apunta al sprite

    ;con el alto del sprite hago las actualizaciones necesarias a la rutina
    ld a,(de)
    ld (#loop_alto_map_sbuffer2+2),a
    ld b,a
    ld a,#ancho_pantalla_bytes
    sub b
    ;ld (#ancho_22+1),a
    ld c,a
	inc de
	ld a,(de)
	inc de

	;ld a,16		;necesito el alto del sprite



sp_buffer_mask2:
	ld b,#0
ancho_22:
	;ld c,#ancho_pantalla_bytes-4 ;60	;;DEPENDE DEL ANCHO

	.db #0xDD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	;ld ixh,a
loop_alto_map_sbuffer2:
		.db #0xDD
		LD L,#4		;ANCHO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		;ld ixl,#4
		ex de,hl
loop_ancho_map_sbuffer2:


		LD A,(hl)	;leo el byte del fondo
		;AND (HL)	;lo enmascaro
		;INC HL
		;OR (HL)		;lo enmascaro
		LD (de),A	;actualizo el fondo
		INC DE
		INC HL


		.db #0xDD
		DEC L		;resta ancho
		;dec ixl
		JP NZ,loop_ancho_map_sbuffer2

	   .db #0xDD
	   dec H
	   ;dec ixh
	   ret z
	   EX DE,HL
;hay que sumar 72 bytes para pasar a la siguiente línea
		add HL,BC
		jp loop_alto_map_sbuffer2