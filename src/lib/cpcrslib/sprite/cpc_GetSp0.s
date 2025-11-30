.module sprites
.include "sprites.s"

_cpc_GetSp0::
	.DB #0XFD
	LD H,c		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
loop_alto_2x_GetSp0:
	LD C,#0
loop_ancho_2x_GetSp0:
	LD A,(HL)
	LD (DE),A
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2x_GetSp0
	.DB #0XFD
	DEC H
	RET Z
salto_lineax_GetSp0:
	LD C,#0XFF					;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2x_GetSp0 			;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7						;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2x_GetSp0