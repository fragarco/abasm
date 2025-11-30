.module gphstr

.include "gphstr.s"

.globl _cpc_PrintGphStrM1

_cpc_PrintGphStrM1::
;preparación datos impresión. El ancho y alto son fijos!

	pop af
	pop de
	pop hl
	push af
	
	XOR A
	push ix
	push iy
	call _cpc_PrintGphStr0M1
	pop iy
	pop ix
	ret
