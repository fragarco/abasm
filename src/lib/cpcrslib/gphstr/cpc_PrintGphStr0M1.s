.module gphstr

.include "gphstr.s"

; Si COLA_IMPRESION = 0 no se compila la gestión de cola de impresión. Por lo general no se requiere.
; COLA_IMPRESION = 1 recomendado si se va a imprimir desde interrupciones, para que no se espere a terminar de imprimir para salir de la impresión (Usado en Columns 2)


COLA_IMPRESION = 0

.if COLA_IMPRESION


	
_cpc_PrintGphStr0M1:
	;DE destino
	;HL origen
	;ex de,hl
	LD (#dobleM1),A
	;trabajo previo: Para tener una lista de trabajos de impresión. No se interrumpe
	;la impresión en curso.
	LD A,(#imprimiendo)
	CP #1
	JP Z,add_elemento
	LD (#direcc_destino),HL
	EX DE,HL
	CALL bucle_texto0M1
;antes de terminar, se mira si hay algo en cola.
bucle_cola_impresionM1:
	LD A,(#elementos_cola)
	OR A
	JP Z,terminar_impresion
	CALL leer_elemento
	JP bucle_cola_impresionM1





bucle_texto0M1:
	LD A,#1
	LD (#imprimiendo),A

	LD A,#FIRST_CHAR
	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)
	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB B
	LD BC,#_cpc_Chars	;apunto a la primera letra
	PUSH HL
	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letraM1
	LD A,(dobleM1)
	CP #1
	; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letraM1
	LD HL,(direcc_destino)
	LD A,(dobleM1)
	CP #1
	;alto
	JR Z,cont_dobleM1
	LD DE,#letra_decodificada
	.DB #0xfD
	LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	JR cont_totM1
.else


_cpc_PrintGphStr0M1:
	;DE destino
	;HL origen
	;ex de,hl
	LD (#dobleM1),A
	;trabajo previo: Para tener una lista de trabajos de impresión. No se interrumpe
	;la impresión en curso.

	LD (#direcc_destino),HL
	EX DE,HL

bucle_texto0M1:


	LD A,#FIRST_CHAR
	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)
	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB B
	LD BC,#_cpc_Chars	;apunto a la primera letra
	PUSH HL
	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letraM1
	LD A,(dobleM1)
	CP #1
	; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letraM1
	LD HL,(direcc_destino)
	LD A,(dobleM1)
	CP #1
	;alto
	JR Z,cont_dobleM1
	LD DE,#letra_decodificada
	.DB #0xfD
	LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	JR cont_totM1
	


.endif

cont_dobleM1:
	LD DE,#letra_decodificada_tmp
	.DB #0XFD
	LD H,#16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
cont_totM1:
	CALL cpc_PutSp0M1
	LD HL,(#direcc_destino)
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0M1

dobleM1:
	.DB #0
;.imprimiendo defb 0
;.direcc_destino defw 0

doblar_letraM1:
	LD HL,#letra_decodificada
	LD DE,#letra_decodificada_tmp
	LD B,#8
buc_doblar_letraM1:
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	LD (DE),A
	INC DE
	DJNZ buc_doblar_letraM1
	RET


cpc_PutSp0M1:
	;	defb #0xfD
   	;	LD H,8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
	LD C,B
loop_alto_2M1:
loop_ancho_2M1:
	EX DE,HL
	LDI
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
salto_lineaM1:
	LD C,#0XFF			;#0x07f6 			;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2M1 ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2M1



escribe_letraM1:
	LD IY,#letra_decodificada
	LD B,#8
	LD IX,#byte_tmp
bucle_altoM1:
	PUSH BC
	PUSH HL

	LD A,(HL)
	LD HL,#dato
	LD (HL),A
	;me deja en ix los valores convertidos
	;HL tiene la dirección origen de los datos de la letra
	;LD DE,letra	;el destino es la posición de decodificación de la letra
	;Se analiza el byte por parejas de bits para saber el color de cada pixel.
	LD (IX),#0	;reset el byte
	LD B,#4	;son 4 pixels por byte. Los recorro en un bucle y miro qué color tiene cada byte.
bucle_coloresM1:
	;roto el byte en (HL)
	PUSH HL
	CALL op_colores_m1	;voy a ver qué color es el byte. tengo un máximo de 4 colores posibles en modo 0.
	POP HL
	SRL (HL)
	SRL (HL)	;voy rotando el byte para mirar los bits por pares.
	DJNZ bucle_coloresM1
	LD A,(IX)
	LD (IY),A
	INC IY
	POP HL
	INC HL
	POP BC
	DJNZ bucle_altoM1
	RET


;.rutina
;HL tiene la dirección origen de los datos de la letra

;Se analiza el byte por parejas de bits para saber el color de cada pixel.
;ld ix,byte_tmp
;ld (ix+0),0

;LD B,4	;son 4 pixels por byte. Los recorro en un bucle y miro qué color tiene cada byte.
;.bucle_colores
;roto el byte en (HL)
;push hl
;call op_colores_m1	;voy a ver qué color es el byte. tengo un máximo de 4 colores posibles en modo 0.
;pop hl
;sla (HL)
;sla (HL)	;voy rotando el byte para mirar los bits por pares.

;djnz bucle_colores

;ret
op_colores_m1:   	;rutina en modo 1
					;mira el color del bit a pintar
	LD A,#3			;hay 4 colores posibles. Me quedo con los 2 primeros bits
	AND (HL)
	; EN A tengo el número de bytes a sumar!!
	LD HL,#colores_m1
	LD E,A
	LD D,#0
	ADD HL,DE
	LD C,(HL)
	;EN C ESTÁ EL BYTE DEL COLOR
	;LD A,4
	;SUB B
	LD A,B
	DEC A
	OR A ;CP 0
	JP Z,_sin_rotar
rotando:
	SRL C
	DEC A
	JP NZ, rotando
_sin_rotar:
	LD A,C
	OR (IX)
	LD (IX),A
	;INC IX
	RET





colores_cambM1:
colores_m1:
	.DB #0b00000000,#0b10001000,#0b10000000,#0b00001000



direcc_destino:
	.dw	#0

dato:
	.DB #0b00011011  ;aquí dejo temporalmente el byte a tratar

byte_tmp:
	.DB #0
	.DB #0
	.DB #0  ;defs 3
