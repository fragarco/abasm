.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_SuperbufferAddress

_cpc_SuperbufferAddress::
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


  ;lo cambio para la rutina de multiplicar
    ld a,8 (ix)
    ld e,9 (ix)
; 	include "multiplication1.asm"
   	    ;ld    h, #ancho_pantalla_bytes
        ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256
        LD    D, L
        LD    B, #8

MULT6:   ADD   HL, HL
        JR    NC, NOADD6
        ADD   HL, DE
NOADD6:  DJNZ  MULT6


	;ld b,#0
	ld e,a
	add hl,de
	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)
    ld 4 (ix),l
    ld 5 (ix),h
    ret

