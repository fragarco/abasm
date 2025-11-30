.module sprites
.include "sprites.s"

.globl _cpc_PutSpXOR

_cpc_PutSpXOR::	; dibujar en pantalla el sprite
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

    LD (#anchox0+#1),A		;actualizo rutina de captura
	SUB #1
	CPL
	LD (#suma_siguiente_lineax0+#1),A    ;comparten los 2 los mismos valores.

	push iy
	call _cpc_PutSpXOR0
	pop iy
	ret