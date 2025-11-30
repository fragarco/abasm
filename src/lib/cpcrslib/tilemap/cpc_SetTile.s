.module tilemap

.include "TileMap.s"
.include "TileMapC.h"


.globl _cpc_SetTile

_cpc_SetTile::


	ld hl,#2
	add hl,sp
	ld a,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld c,(hl)


		LD	  HL,#ancho_pantalla_bytes * 128
        LD    D, L
        LD    B, #8

MULT:   ADD   HL, HL
        JR    NC, NOADD
        ADD   HL, DE
NOADD:  DJNZ  MULT

	ld e,a
	;ld d,#0		
	add hl,de

	ld de,#_pantalla_juego
	add hl,de
	ld (hl),c

	ret