.module sprites

.include "sprites.s"

.globl _cpc_PutTile2x8b

_cpc_PutTile2x8b::


pop af

pop de
pop hl
push af

push ix
call _int_cpc_PutTile2x80
pop ix
ret

