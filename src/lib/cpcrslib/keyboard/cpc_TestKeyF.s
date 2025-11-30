.module keyboard

.include "keyboard.s"

.globl _cpc_TestKeyF

_cpc_TestKeyF::

	SLA L
	INC L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE
	LD A,(HL)
	SUB #0X40
	EX DE,HL
	LD HL,#keymap		; LEE LA LÍNEA BUSCADA DEL KEYMAP
	LD C,A
	LD B,#0
	ADD HL,BC
	LD A,(HL)
	EX DE,HL
	DEC HL				; PERO SÓLO NOS INTERESA UNA DE LAS TECLAS.
	AND (HL) 			; PARA FILTRAR POR EL BIT DE LA TECLA (PUEDE HABER VARIAS PULSADAS)
	CP (HL)				; COMPRUEBA SI EL BYTE COINCIDE
	LD H,#0
	JP NZ,#pulsado_cpc_TestKeyF
	LD L,H
	RET
pulsado_cpc_TestKeyF:
	LD L,#1
	RET