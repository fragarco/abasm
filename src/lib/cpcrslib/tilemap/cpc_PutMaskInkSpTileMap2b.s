.module tilemap

.include "TileMap.s"
.include "TileMapC.h"
		
.globl _cpc_PutMaskInkSpTileMap2b

_cpc_PutMaskInkSpTileMap2b::
	push ix
	call rutina
	pop ix
	ret

rutina:
		ex de,hl

	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS


    ld a,8 (ix)
    ld e,9 (ix)

;include "multiplication1.asm"
   	    ;ld    h, #ancho_pantalla_bytes
  	    ;LD    L, #0
        LD	  HL, #ancho_pantalla_bytes*256
        LD    D, L
        LD    B, #8

MULT7:   ADD   HL, HL
        JR    NC, NOADD7
        ADD   HL, DE
NOADD7:  DJNZ  MULT7

	ld e,a
	add hl,de
	;HL=E*H+D

	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)

	ld 4 (ix),l		;update superbuffer address
    ld 5 (ix),h

	ld e,0 (ix)
    ld d,1 (ix)	;HL apunta al sprite

    ;con el ancho del sprite hago las actualizaciones necesarias a la rutina
    ld a,(de)
    ld (#loop_alto_map_sbuffer7+2),a
    ld b,a
    ld a,#ancho_pantalla_bytes
    sub b
    ;ld (#ancho_27+1),a
    ld c,a
	inc de
	ld a,(de)
	inc de


sp_buffer_mask7:
	ld b,#0
ancho_27:
	;ld c,#ancho_pantalla_bytes-4 ;60	;;DEPENDE DEL ANCHO

	.db  #0xdd
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	;ld ixh,a
loop_alto_map_sbuffer7:
		.db  #0xdd
		LD L,#4		;ANCHO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		;ld ixl,4
		ex de,hl
		
loop_ancho_map_sbuffer7:


		LD A,(hl)	;leo el byte del fondo
		or a
		jp z, cont7
		
		LD (DE),A	;actualizo el fondo
cont7:
		INC DE
		INC HL

		.db  #0xdD
		DEC L		;resta ancho
		;dec ixl
		JP NZ,loop_ancho_map_sbuffer7

	   .db  #0xdd
	   dec H
	   ;dec ixh
	   ret z
	   EX DE,HL
;hay que sumar 72 bytes para pasar a la siguiente línea
		add HL,BC
		jp loop_alto_map_sbuffer7
		