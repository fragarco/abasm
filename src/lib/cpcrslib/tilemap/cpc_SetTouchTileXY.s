.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_SetTouchTileXY

_cpc_SetTouchTileXY::




	ld hl,#2
	add hl,sp
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)



	call _cpc_UpdTileTable


	ld a,e
	ld e,d

        LD	  HL,#ancho_pantalla_bytes * 256 / 2
        LD    D, L
        LD    B, #8

MULT4:   ADD   HL, HL
        JR    NC, NOADD4
        ADD   HL, DE
NOADD4:  DJNZ  MULT4


			ld e,a

		add hl,de
		ld de,#_pantalla_juego
		add hl,de

		ld (hl),c
	ret
