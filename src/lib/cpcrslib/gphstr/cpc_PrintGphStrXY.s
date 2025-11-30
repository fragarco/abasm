.module gphstr

.include "gphstr.s"
.include "../video/video.s"

.globl _cpc_PrintGphStrXY

_cpc_PrintGphStrXY::
;preparación datos impresión. El ancho y alto son fijos!
	pop af
	pop de
	pop hl
	push af

	push de
	ld a,L
	CALL _cpc_GetScrAddress0
	pop de
	
	push iy
 	call _cpc_PrintGphStr0
	pop iy
	ret