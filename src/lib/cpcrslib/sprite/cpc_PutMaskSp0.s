.module sprites
.include "sprites.s"

_cpc_PutMaskSp0:
	.DB #0XFD
	LD H,c		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
loop_alto_2m_PutMaskSp0:
	LD C,#4
	EX DE,HL
loop_ancho_2m_PutMaskSp0:
	LD A,(DE)	;LEO EL BYTE DEL FONDO
	AND (HL)	;LO ENMASCARO
	INC HL
	OR (HL)		;LO ENMASCARO
	LD (DE),A	;ACTUALIZO EL FONDO
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2m_PutMaskSp0
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
salto_lineam_PutMaskSp0:
	LD C,#0XFF
	ADD HL,BC
	JP nc,loop_alto_2m_PutMaskSp0
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7
	JP loop_alto_2m_PutMaskSp0