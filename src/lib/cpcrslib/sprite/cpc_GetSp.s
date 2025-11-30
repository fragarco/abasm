.module sprites
.include "sprites.s"

.globl _cpc_GetSp

_cpc_GetSp::

	pop af
	
	pop de
	pop bc
	pop hl
	
	push af
	
	ld a,b



	LD (#loop_alto_2x_GetSp0+1),A


	SUB #1
	CPL
	LD (#salto_lineax_GetSp0+1),A    ;comparten los 2 los mismos valores.

	push iy
	call _cpc_GetSp0
	pop iy
	ret

