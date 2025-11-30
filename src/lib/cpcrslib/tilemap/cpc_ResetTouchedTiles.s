.module tilemap

.include "TileMap.s"



.globl _cpc_ResetTouchedTiles

_cpc_ResetTouchedTiles::
	LD HL,#_tiles_tocados
	LD (HL),#0xFF
	RET