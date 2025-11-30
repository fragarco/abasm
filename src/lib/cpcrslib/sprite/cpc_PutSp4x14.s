.module sprites


.globl _cpc_PutSp4x14

_cpc_PutSp4x14::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af
	pop af
	pop de
	pop hl
	push af
	
	push iy
	call pc_PutSp0X
	pop iy
	ret

pc_PutSp0X:
	.DB #0XFD
	LD H,#14		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
ancho0X:
loop_alto_2:
	LD C,#4

	EX DE,HL
	LDI
	LDI
	LDI
	LDI
	EX DE,HL
	.DB #0XFD
	DEC H
	RET Z

suma_siguiente_linea:

	LD C,#0XFC			 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP nc,loop_alto_2 	;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2