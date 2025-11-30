.module sprites
.include "sprites.s"

.globl _cpc_PutSpTr

_cpc_PutSpTr::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af
	pop af
	
	pop de
	pop bc
	pop hl
	
	push af
	
	ld a,b


    LD (#anchot+1),A	;actualizo rutina de dibujo
	SUB #1
	CPL
	LD (#suma_siguiente_lineat+1),A    ;comparten los 2 los mismos valores.

	push iy
	call  _cpc_PutSpTr0
	pop ix
	ret