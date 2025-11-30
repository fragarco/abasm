.module gphstr

.include "gphstr.s"

cpc_ColaImpresion:

terminar_impresion:
	XOR A
	LD (#imprimiendo),A
	RET
entrar_cola_impresion:
;si se está imprimiendo se mete el valor en la cola
	RET
add_elemento:
	DI
	LD IX,(#pos_cola)
	LD 0 (IX),L
	LD 1 (IX),H
	LD 2 (IX),E
	LD 3 (IX),D
	INC IX
	INC IX
	INC IX
	INC IX
	LD (#pos_cola),IX

	LD HL,#elementos_cola
	INC (HL)
	;Se añaden los valores hl y de
	EI
	RET
leer_elemento:
	DI
	LD IX,(#pos_cola)
	LD L,0 (IX)
	LD H,1 (IX)
	LD E,2 (IX)
	LD D,4 (IX)
	DEC IX
	DEC IX
	DEC IX
	DEC IX
	LD (#pos_cola),IX
	LD HL,#elementos_cola
	DEC (HL)
	EI
	RET

elementos_cola:
	.DW #0				; defw 0
pos_cola:
	.DW #cola_impresion ;defw cola_impresion
						;pos_escritura_cola defw cola_impresion
cola_impresion:  		; defs 12
	.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	
imprimiendo:
	.DB #0	