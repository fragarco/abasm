.module keyboard

.include "keyboard.s"

.globl _cpc_TestKey

_cpc_TestKey::

; En L se tiene el valor de la tecla seleccionada a comprobar [0..11]
	SLA L
	INC L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE
	LD A,(HL)
	CALL _cpc_TestKeyboard		; esta rutina lee la línea del teclado correspondiente
	DEC HL						; pero sólo nos interesa una de las teclas.
	and (HL) 					;para filtrar por el bit de la tecla (puede haber varias pulsadas)
	CP (HL)						;comprueba si el byte coincide
	LD H,#0
	JP Z,pulsado
	LD L,H
	RET
pulsado:
	LD L,#1
	RET