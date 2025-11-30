.module sprites

.globl _cpc_PutSp

_cpc_PutSp::	; dibujar en pantalla el sprite
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
    LD (#ancho0+1),A		;actualizo rutina de dibujo
							
	SUB #1
	CPL
	LD (#suma_siguiente_linea0+1),A    ;COMPARTEN LOS 2 LOS MISMOS VALORES.

	push iy
	call pc_PutSp0
	pop iy
	ret


pc_PutSp0:
	.DB #0XFD
	LD H,c		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
ancho0:
loop_alto_2_pc_PutSp0:
	LD C,#4
loop_ancho_2_pc_PutSp0:
	LD A,(DE)
	LD (HL),A
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2_pc_PutSp0
	.DB #0XFD
	DEC H
	RET Z

suma_siguiente_linea0:
salto_linea_pc_PutSp0:
	LD C,#0XFF			;&07F6 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP nc,loop_alto_2_pc_PutSp0 ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050

	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2_pc_PutSp0