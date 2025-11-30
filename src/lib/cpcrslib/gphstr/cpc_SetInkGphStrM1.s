.module gphstr

.include "gphstr.s"


.globl _cpc_SetInkGphStrM1

_cpc_SetInkGphStrM1::
	pop af
	pop bc
	push af
	ld a,b
	
	LD HL,#colores_m1
	LD B,#0
	ADD HL,BC
	LD (HL),A
	RET