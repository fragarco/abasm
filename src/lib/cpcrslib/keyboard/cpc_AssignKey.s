.module keyboard

.include "keyboard.s"

.globl _cpc_AssignKey

_cpc_AssignKey::

	LD HL,#2
    ADD HL,SP
	LD E,(HL)		;E-> numero tecla
	INC HL

	
    LD A,(HL)					;linea, byte
    INC HL
    LD B,(HL)					;DE tiene el valor de la tecla a escribir en la tabla
								; En A se tiene el valor de la tecla seleccionada a comprobar [0..11]
								;___________________________________________________________________
								;	;En A viene la tecla a redefinir (0..11)
								
	SLA E
	LD D,#0
	LD HL, #tabla_teclas
	ADD HL,DE 					;Nos colocamos en la tecla a redefinir y la borramos
	LD (HL),#0XFF
	INC HL
	LD (HL),#0XFF
	DEC HL
	PUSH HL
								;call ejecutar_deteccion_teclado ;A tiene el valor del teclado
								; A tiene el byte (<>0)
								; B tiene la linea
								;guardo linea y byte
	POP HL
	LD (HL),A ;byte
	INC HL
	LD (HL),B
	RET