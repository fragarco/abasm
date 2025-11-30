.module keyboard

.include "keyboard.s"

.globl _cpc_RedefineKey

_cpc_RedefineKey::


	SLA L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE 					;Nos colocamos en la tecla a redefinir
	LD (HL),#0XFF				; y la borramos
	INC HL
	LD (HL),#0XFF
	DEC HL
	PUSH HL
	CALL ejecutar_deteccion_teclado ;A tiene el valor del teclado
	LD A,D
								; A tiene el byte (<>0)
								; B tiene la linea
								;guardo linea y byte
	POP HL						;recupera posición leída
	LD A,(linea)
	LD (HL),A 					;byte
	INC HL
	LD A,(bte)
	LD (HL),A
	RET


ejecutar_deteccion_teclado:
	LD A,#0x40
bucle_deteccion_tecla1:
	PUSH AF
	LD (bte),A
	CALL _cpc_TestKeyboard					;en A vuelve los valores de la linea
	OR A
	JR NZ, tecla_pulsada1					; retorna si no se ha pulsado ninguna tecla
	POP AF
	INC A
	CP #0x4A
	JR NZ, bucle_deteccion_tecla1
	JR ejecutar_deteccion_teclado

tecla_pulsada1:
	LD (linea),A
	POP AF
	CALL comprobar_si_tecla_usada
	RET NC
	JR bucle_deteccion_tecla1

comprobar_si_tecla_usada: 				; A tiene byte, B linea
	LD B,#12							;numero máximo de tecla redefinibles
	LD IX,#tabla_teclas
	LD C,(IX)
bucle_bd_teclas:						;comprobar byte
	LD A,(linea)
	LD C,(IX)
	CP (IX)
	JR Z, comprobar_linea
	INC IX
	INC IX
	DJNZ bucle_bd_teclas
	SCF
	CCF
	RET									; si vuelve después de comprobar, que sea NZ
comprobar_linea:						;si el byte es el mismo, mira la linea
	LD A,(bte)
	CP 1 (IX)							; esto es (ix+1)
	JR Z, tecla_detectada				; Vuelve con Z si coincide el byte y la linea
	INC IX
	INC IX
	DJNZ bucle_bd_teclas
	SCF
	CCF
	RET 								; si vuelve después de comprobar, que sea NZ
tecla_detectada:
	SCF
	RET