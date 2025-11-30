.module sprites

.include "sprites.s"
.include "../video/video.s"

.globl _cpc_PutTile2x8

_cpc_PutTile2x8:: ;siempre se dibujan en posicion caracter así que no hay saltos raros en HL, se puede quitar la última parte

push ix
call rutina
pop ix
ret
rutina:
jp opop

.db 'r','a','u','l'

opop:
	LD IX,#6
	ADD IX,SP

	ld H,3 (IX)
	ld A,2 (IX)	;pantalla
	
	call _cpc_GetScrAddress0
		
	ld E,0 (IX)
	ld D,1 (IX)	;DE sprite
	jp _int_cpc_PutTile2x80
