.module gphstr

.include "gphstr.s"

.globl _cpc_SetInkGphStr

_cpc_SetInkGphStr::
;preparación datos impresión. El ancho y alto son fijos!
	;LD IX,#2
	;ADD IX,SP


	;LD A,1 (IX) ;VALOR
	;LD C,0 (IX)	;COLOR
	
	
	pop af
	pop bc
	push af
	ld a,b
	
	LD HL,#colores_b0
	LD B,#0
	ADD HL,BC
	LD (HL),A
	RET
