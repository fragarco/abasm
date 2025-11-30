.module sprites
.include "sprites.s"

_cpc_PutSpXOR0:
	.DB #0XFD
	LD H,C		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
anchox0:
loop_alto_2x:
	LD C,#4
loop_ancho_2x:
	LD A,(DE)
	XOR (HL)
	LD (HL),A
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2x
	.DB #0XFD
	DEC H
	RET Z

suma_siguiente_lineax0:
salto_lineax:
	LD C,#0XFF			 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP NC,loop_alto_2x 		;SI NO DESBORDA VA A LA SIGUIENTE LINEA
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2x