.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_ScrollLeft01

_cpc_ScrollLeft01::

	;se incrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma14:
	INC (HL)
	INC HL
	INC HL
	djnz buc_suma14


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	dec HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL


	ld hl,#_pantalla_juego+1
	ld de,#_pantalla_juego
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes/16 -1
	LDIR

	ld hl,#posicion_inicial_superbuffer+2
	ld de,#posicion_inicial_superbuffer
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes -1
	LDIR

	RET