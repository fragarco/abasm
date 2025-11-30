.module gphstr

.include "gphstr.s"


.globl _cpc_PrintGphStrM12X

_cpc_PrintGphStrM12X::
	pop af
	pop de
	pop hl
	push af
	LD A,#1

	push ix
	push iy
	call _cpc_PrintGphStr0M1
	pop iy
	pop ix
	ret