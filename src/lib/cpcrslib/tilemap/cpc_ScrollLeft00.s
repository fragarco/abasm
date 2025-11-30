.module tilemap

.include "TileMap.s"

.globl _cpc_ScrollLeft00

_cpc_ScrollLeft00::

	;se decrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma1:
	DEC (HL)
	INC HL
	INC HL
	djnz buc_suma1

	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	inc HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	RET