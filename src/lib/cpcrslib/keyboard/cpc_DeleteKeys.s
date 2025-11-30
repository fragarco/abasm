.module keyboard

.include "keyboard.s"


.globl _cpc_DeleteKeys

_cpc_DeleteKeys::		;borra la tabla de las teclas para poder redefinirlas todas
	LD HL,#tabla_teclas
	LD DE,#tabla_teclas+#1
	LD BC, #32
	LD (HL),#0xFF
	LDIR
	RET