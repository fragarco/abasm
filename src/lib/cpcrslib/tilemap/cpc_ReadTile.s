.module tilemap

.include "TileMap.s"
.include "TileMapC.h"


.globl _cpc_ReadTile

_cpc_ReadTile::



	pop af
	pop de
	push af
	
	ld a,e
	ld e,d
	
	
;	ld hl,#2
;	add hl,sp
;	ld a,(hl)
;	inc hl
;	ld e,(hl)


        LD	  HL,#ancho_pantalla_bytes*128
        LD    D, L
        LD    B, #8

MULT5:   ADD   HL, HL
        JR    NC, NOADD5
        ADD   HL, DE
NOADD5:  DJNZ  MULT5



			ld e,a
			;ld d,#0
		add hl,de		;SUMA X A LA DISTANCIA Y*ANCHO
	ld de,#_pantalla_juego
		add hl,de
		ld l,(hl)
		ld h,#0
	ret