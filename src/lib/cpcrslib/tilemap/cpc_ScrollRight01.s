.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_ScrollRight01

_cpc_ScrollRight01::	;;scrollea el area de pantalla de tiles

	;se incrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma15:
	DEC (HL)
	INC HL
	INC HL
	djnz buc_suma15


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	inc HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	ld hl,#_pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16-1
	ld de,#_pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes/16 -1 ;-1
	LDDR

	;scrollea el superbuffer
	ld hl,#posicion_inicial_superbuffer+alto_pantalla_bytes*ancho_pantalla_bytes-2 ; pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16-1
	ld de,#posicion_inicial_superbuffer+alto_pantalla_bytes*ancho_pantalla_bytes ;pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes-1 ;-1
	LDDR
	RET