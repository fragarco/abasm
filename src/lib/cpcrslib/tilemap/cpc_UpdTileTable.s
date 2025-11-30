.module tilemap

.include "TileMap.s"


_cpc_UpdTileTable::
; En DE word a comprobar (fila/columna o al revés)
	LD HL,#_tiles_tocados
	;incorporo el tile en su sitio, guardo x e y
bucle_recorrido_tiles_tocados:
	LD A,(HL)
	CP #0xFF
	JP Z,incorporar_tile	;Solo se incorpora al llegar a un hueco
	CP E
	JP Z, comprobar_segundo_byte
	INC HL
	INC HL
	JP bucle_recorrido_tiles_tocados
comprobar_segundo_byte:
	INC HL
	LD A,(HL)
	CP D
	RET Z	;los dos bytes son iguales, es el mismo tile. No se añade
	INC HL
	JP bucle_recorrido_tiles_tocados

incorporar_tile:
	LD (HL),E
	INC HL
	LD (HL),D
	INC HL
	LD (HL),#0xFF	;End of data
	RET
