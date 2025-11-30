.module sprites
.include "sprites.s"

.globl _cpc_PutSpriteXOR

_cpc_PutSpriteXOR::	; dibujar en pantalla el sprite
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
    LD (#anchox0+#1),A	;ACTUALIZO RUTINA DE DIBUJO	
	SUB #1
	CPL
	LD (#suma_siguiente_lineax0+1),A    ;COMPARTEN LOS 2 LOS MISMOS VALORES.
	LD c,(HL)	;ALTO
	INC HL
	EX DE,HL
	
	push iy
	call _cpc_PutSpXOR0
	pop iy
	ret