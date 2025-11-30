.module gphstr


.include "gphstr.s"




; Si COLA_IMPRESION = 0 no se compila la gestión de cola de impresión. Por lo general no se requiere.
; COLA_IMPRESION = 1 recomendado si se va a imprimir desde interrupciones, para que no se espere a terminar de imprimir para salir de la impresión (Usado en Columns 2)

COLA_IMPRESION = 0	



.if COLA_IMPRESION
_cpc_PrintGphStr0::

	;DE destino
	;HL origen
	;ex de,hl
	LD (#doble),A
	;trabajo previo: Para tener una lista de trabajos de impresión. No se interrumpe
	;la impresión en curso.
	LD A,(#imprimiendo)
	CP #1
	JP Z,add_elemento
	LD (#direcc_destino),HL
	EX DE,HL
	CALL bucle_texto0

;antes de terminar, se mira si hay algo en cola.
bucle_cola_impresion:
	LD A,(#elementos_cola)
	OR A
	JP Z,terminar_impresion
	CALL leer_elemento
	JP bucle_cola_impresion


bucle_texto0:
	LD A,#1
	LD (imprimiendo),A

;	LD A,(_first_char)
;	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)

	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB #FIRST_CHAR
	LD BC,#_cpc_Chars	;apunto a la primera letra
	PUSH HL

	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letra
	LD A,(doble)
	CP #1
; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letra
	LD HL,(#direcc_destino)
	LD A,(doble)
	CP #1
	;alto
	ld a,#8
	JR Z,cont_doble
	LD DE,#letra_decodificada
	;.DB #0xfD
	;LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	
	
cont_tot:
	CALL cpc_PutSp0
	LD HL,(#direcc_destino)
	INC HL
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0

cont_doble:
	LD DE,#letra_decodificada_tmp
	;.DB #0xfD
	;LD H,#16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	
	sla a
	
	;ld a,#16
	JR cont_tot

.else


_cpc_PrintGphStr0::

	;DE destino
	;HL origen
	;ex de,hl
	LD (#doble),A
	LD (#direcc_destino),HL
	EX DE,HL



bucle_texto0:


	;LD A,(_first_char)
	;LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)

	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB #FIRST_CHAR 
	LD BC,#_cpc_Chars	;apunto a la primera letra
	PUSH HL

	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letra
	LD A,(doble)
	CP #1
; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letra
	LD HL,(#direcc_destino)
	LD A,(doble)
	CP #1
	;alto
	ld a,#8
	JR Z,cont_doble
	LD DE,#letra_decodificada
	;.DB #0xfD
	;LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	
	;ld a,#8
	
cont_tot:
	CALL cpc_PutSp0
	LD HL,(#direcc_destino)
	INC HL
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0

cont_doble:
	sla a
	LD DE,#letra_decodificada_tmp
	;.DB #0xfD
	;LD H,#16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	
	;ld a, #16
	JR cont_tot

	
.endif
doble:
	.DB #0

direcc_destino:
	.DW #0


cpc_PutSp0:
;	.DB #0xfD
;  		LD H,16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE

	LD B,#7
	LD C,B
loop_alto_2:

loop_ancho_2:
	EX DE,HL
	LDI
	LDI
;	.DB #0XFD
;	DEC H
	dec a
	RET Z
	EX DE,HL
salto_linea:
	LD C,#0XFE			 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP NC,loop_alto_2 		;SI NO DESBORDA VA A LA SIGUIENTE LINEA
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2




doblar_letra:
	LD HL,#letra_decodificada
	LD DE,#letra_decodificada_tmp
	LD B,#8
buc_doblar_letra:
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	INC DE
	LD (DE),A
	DEC DE
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	INC DE
	LD (DE),A
	INC DE
	DJNZ buc_doblar_letra
	RET


escribe_letra:		; Code by Kevin Thacker
	PUSH DE
	LD IY,#letra_decodificada
	LD B,#8
bucle_alto_letra:
	PUSH BC
	PUSH HL
	LD E,(HL)
	CALL op_colores
	LD (IY),D
	INC IY
	CALL op_colores
	LD (IY),D
	INC IY
	POP HL
	INC HL
	POP BC
	DJNZ bucle_alto_letra
	POP DE
	RET

op_colores:
	ld d,#0					;; initial byte at end will be result of 2 pixels combined
	CALL op_colores_pixel	;; do pixel 0
	RLC D
	CALL op_colores_pixel
	RRC D
	RET

;; follow through to do pixel 1

op_colores_pixel:
	;; shift out pixel into bits 0 and 1 (source)
	RLC E
	RLC E
	;; isolate
	LD A,E
	AND #0X3
	LD HL,#colores_b0
	ADD A,L
	LD L,A
	LD A,H
	ADC A,#0
	LD H,A
	;; READ IT AND COMBINE WITH PIXEL SO FAR
	LD A,D
	OR (HL)
	LD D,A
	RET