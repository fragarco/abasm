.module sprites
.include "sprites.s"

_cpc_PutMaskSp::	; dibujar en pantalla el sprite
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
    ld (#loop_alto_2m_PutMaskSp0+#1),a		;actualizo rutina de captura
	SUB #1
	CPL
	LD (#salto_lineam_PutMaskSp0+#1),A    ;comparten los 2 los mismos valores.
	
	push iy
	call _cpc_PutMaskSp0
	pop iy
	ret