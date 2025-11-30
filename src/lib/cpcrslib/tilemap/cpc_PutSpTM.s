.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_PutSpTM

_cpc_PutSpTM::	; dibujar en pantalla el sprite

;di
ld a,b
ld b,c
ld c,a
loop_alto_2_cpc_PutSpTM:
	push bc
	ld b,c
	push hl
loop_ancho_2_cpc_PutSpTM:
	ld A,(DE)
	ld (hl),a
	inc de
	inc hl
	djnz loop_ancho_2_cpc_PutSpTM

	;incremento DE con el ancho de la pantalla-el del sprite
	ex de,hl
ancho_mostrable:
	ld bc,#tiles_ocultos_ancho0*4
	add hl,bc
	ex de,hl
	pop hl
	ld A,H
	add #0x08
	ld H,A
	sub #0xC0
	jp nc,sig_linea_2_cpc_PutSpTM
	ld bc,#0xc050
	add HL,BC
sig_linea_2_cpc_PutSpTM:
	pop BC
	djnz loop_alto_2_cpc_PutSpTM
;ei
ret
