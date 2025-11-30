.module tilemap

.include "TileMap.s"

.globl _cpc_ScrollRight00

_cpc_ScrollRight00::		;;scrollea el area de pantalla de tiles

	;se decrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma12:
	INC (HL)
	INC HL
	INC HL
	djnz buc_suma12


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	dec HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	RET