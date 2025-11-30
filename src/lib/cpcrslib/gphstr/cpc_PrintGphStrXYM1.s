.module gphstr

.include "gphstr.s"
.include "../video/video.s"

.globl _cpc_PrintGphStrXYM1

_cpc_PrintGphStrXYM1::
;preparación datos impresión. El ancho y alto son fijos!
	pop af
	pop de
	pop hl
	push af

	push de
	ld a,L
	CALL _cpc_GetScrAddress0
	pop de
	XOR A
	push ix
	push iy
	call _cpc_PrintGphStr0M1
	pop iy
	pop ix
	ret