.module gphstr

.include "gphstr.s"

.globl _cpc_PrintGphStr2X

_cpc_PrintGphStr2X::
;preparación datos impresión. El ancho y alto son fijos!
	;LD IX,#2
	;ADD IX,SP
	;LD L,2 (IX)
	;LD H,3 (IX)	;DESTINO
   	;LD E,0 (IX)
	;LD D,1 (IX)	;TEXTO ORIGEN
	
	
	pop af
	pop de
	pop hl
	push af
	
	
	LD A,#1
	

	push iy
	call _cpc_PrintGphStr0
	pop iy

	ret
