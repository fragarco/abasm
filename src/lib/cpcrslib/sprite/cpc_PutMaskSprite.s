.module sprites
.include "sprites.s"

.globl _cpc_PutMaskSprite

_cpc_PutMaskSprite::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af

	POP AF
	POP HL
	POP DE
	PUSH AF
	LD A,(HL)		;ANCHO
	INC HL
    ld (#loop_alto_2m_PutMaskSp0+#1),a		;ACTUALIZO RUTINA

	SUB #1
	CPL
	LD (#salto_lineam_PutMaskSp0+#1),A    ;COMPARTEN LOS 2 LOS MISMOS VALORES.
	LD c,(HL)	;ALTO
	INC HL
	EX DE,HL
	
	push iy
	call _cpc_PutMaskSp0
	pop iy
	ret