.module tilemap

.include "TileMap.s"

.globl _cpc_InitTileMap

_cpc_InitTileMap::
	LD HL,#0
	LD (_tiles),HL
	RET