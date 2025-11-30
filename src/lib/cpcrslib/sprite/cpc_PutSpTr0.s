.module sprites
.include "sprites.s"


_cpc_PutSpTr0:
	.DB #0XFD
	LD H,c		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
anchot:
loop_alto_2t:
	LD B,#0
loop_ancho_2t:
	LD A,(DE)
	AND #0XAA
	JP Z,sig_pixn_der_2
	LD C,A ;B es el único registro libre
	LD A,(HL) ;pixel actual donde pinto
	AND #0X55
	OR C
	LD (HL),A ;y lo pone en pantalla
sig_pixn_der_2:
	LD A,(DE) ;pixel del sprite
	AND #0X55
	JP Z,pon_buffer_der_2
	LD C,A ;B es el único registro libre
	LD A,(HL) ;PIXEL ACTUAL DONDE PINTO
	AND #0XAA
	OR C
	LD (HL),A
pon_buffer_der_2:
	INC DE
	INC HL
	DEC B
	JP NZ,loop_ancho_2t
	.DB #0XFD
	DEC H
	RET Z
suma_siguiente_lineat:
salto_lineat:
	LD BC,#0X07FF			;&07f6 			;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2t ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	;ld b,7			;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2t

	LD A,H
	ADD #0X08
	LD H,A
	SUB #0XC0
	JP NC,loop_alto_2t ;sig_linea_2
	LD BC,#0XC050
	ADD HL,BC
	JP loop_alto_2t