; Code adapted to ABASM syntax by Javier "Dwayne Hicks" Garcia
; Based on CPCRSLIB:
; Copyright (c) 2008-2015 Raúl Simarro <artaburu@hotmail.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of
; this software and associated documentation files (the "Software"), to deal in the
; Software without restriction, including without limitation the rights to use, copy,
; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so, subject to the
; following conditions:
;
; The above copyright notice and this permission notice shall be included in all copies
; or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
; FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.

read 'cpcrslib/keyboard/vars.asm'
read 'cpcrslib/keyboard/testkeyboard.asm'

; CPC_TESTKEY
; Checks if any key in the keyboard is pressed. If so, it returns -1 (True)
; in HL, otherwise it returns 0.
; Inputs:
;     HL Key table index to redefine (0..11)
; Outputs:
;	  HL -1 if at least one key is pressed, 0 otherwise
;     AF, HL, DE, BC, IX and IY are modified.
_cpc_TestKey:

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