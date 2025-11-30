.module tilemap

.include "TileMap.s"
.include "TileMapC.h"


.globl _cpc_ShowTileMap	;	para una pantalla de 64x160 bytes. Superbuffer 8192bytes



_cpc_ShowTileMap::
push ix
call rutina
pop ix
ret


.ifeq T_WH + T_HH


rutina:

	xor a
	ld (#contador_tiles),a
;Se busca el número de tiles en pantalla
	ld hl,(#ntiles)
	ld (#contador_tiles2),hl
	ld hl,#_pantalla_juego
	call transferir_pantalla_a_superbuffer

;parte donde se transfiere el superbuffer completo a la pantalla

	ld hl,#posicion_inicial_superbuffer
	push hl
	ld (#posicion_inicio_pantalla_visible_sb+1),HL


;.otro_ancho
	ld b,#ancho_pantalla_bytes-4*(tiles_ocultos_ancho0)	;nuevo ancho
	ld c,#alto_pantalla_bytes-16*(tiles_ocultos_alto0)			;nuevo alto


; a HL tb se le suma una cantidad

	ld hl,#_posiciones_pantalla

	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	;ld (#posicion_inicio_pantalla_visible+1),HL
	ld (#posicion_inicio_pantalla_visible2+1),HL
	pop de	;origen
	;HL destino
	;DE origen
	;call cpc_PutSpTM		;cambiar la rutina por una que dibuje desde superbuffer
	
	;ret
	jp creascanes
; A partir de la dirección del vector de bloques se dibuja el mapeado en pantalla


transferir_pantalla_a_superbuffer:


	PUSH HL
	POP IX	;IX lleva los datos de la pantalla
	LD DE,(#_posiciones_super_buffer)
bucle_dibujado_fondo:
	;Leo en HL el tile a meter en el superbuffer
	LD L,0 (IX)
	LD H,#0
	ADD HL,HL	;x2
	ADD HL,HL	;x4
	ADD HL,HL	;x8
	ADD HL,HL	;x16
	LD BC,#_tiles
	ADD HL,BC	;hl apunta al tile a transferir
	;me falta conocer el destino. IY apunta al destino
	EX DE,HL
	PUSH HL
	call transferir_map_sbuffer		;DE origen HL destino

; Inicio Mod. 29.06.2009
; Se cambia la forma de controlar el final de datos de tiles. El #0xFF ahora sí que se podrá utilizar.
	ld HL,(#contador_tiles2)
	dec HL
	LD (#contador_tiles2),HL
	LD A,H
	OR L
	jp z, ret2
; Fin    Mod. 29.06.2009
	POP HL
	INC IX	;Siguiente byte

	EX DE,HL
	LD A,(#contador_tiles)
	CP #ancho_pantalla_bytes/2-1 
	JP Z,incremento2
	INC A
	LD (#contador_tiles),A
	INC DE
	INC DE	;para pasar a la siguiente posición
	;si ya se va por el 18 el salto es mayor, es
	JP bucle_dibujado_fondo

incremento2:
	XOR A
	LD (#contador_tiles),A
	LD BC, #7*ancho_pantalla_bytes+2 
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	JP bucle_dibujado_fondo

contador_tiles: .DB 0
contador_tiles2: .DW 0
ntiles: .DW  ( alto_pantalla_bytes / 8 ) * ( ancho_pantalla_bytes / 2	)
ret2:

	pop hl
	ret


transferir_map_sbuffer:

		ld bc,#ancho_pantalla_bytes-1 

		.DB #0xfD
   		LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE

loop_alto_map_sbuffer:
loop_ancho_map_sbuffer:
	ld A,(DE)
	ld (HL),A
	inc de
	inc hl
	ld A,(DE)
	ld (HL),A
	inc de

	.DB #0xfD
	dec h
	ret z
;hay que sumar el ancho de la pantalla en bytes para pasar a la siguiente línea

	add HL,BC
	jp loop_alto_map_sbuffer
	

.else

rutina:

	xor a
	ld (#contador_tiles),a
;Se busca el número de tiles en pantalla
	ld hl,(#ntiles)
	ld (#contador_tiles2),hl
	ld hl,#_pantalla_juego
	call transferir_pantalla_a_superbuffer

;parte donde se transfiere el superbuffer completo a la pantalla

	ld de,#posicion_inicial_superbuffer
	ld hl,#tiles_ocultos_ancho0*2
	add hl,de	;primero posiciona en ancho

	; Posición inicial lectura datos superbuffer
	ld de,#ancho_pantalla_bytes
	ld b,#tiles_ocultos_alto0*8
	XOR A
	CP B
	JR Z, NO_SUMA
bucle_alto_visible:
	add hl,de
	djnz bucle_alto_visible
NO_SUMA:
	push hl
	ld (#posicion_inicio_pantalla_visible_sb+1),HL


;.otro_ancho
	ld b,#ancho_pantalla_bytes-4*(tiles_ocultos_ancho0)	;nuevo ancho
	ld c,#alto_pantalla_bytes-16*(tiles_ocultos_alto0)			;nuevo alto


; a HL tb se le suma una cantidad
	ld de, #tiles_ocultos_alto0*2
	ld hl,#_posiciones_pantalla
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl, #2*tiles_ocultos_ancho0
	add hl,de
	;ld (#posicion_inicio_pantalla_visible+1),HL
	ld (#posicion_inicio_pantalla_visible2+1),HL
	pop de	;origen
	;HL destino
	;DE origen
	;call cpc_PutSpTM		;cambiar la rutina por una que dibuje desde superbuffer
	
	;ret
	jp creascanes
; A partir de la dirección del vector de bloques se dibuja el mapeado en pantalla


transferir_pantalla_a_superbuffer:


	PUSH HL
	POP IX	;IX lleva los datos de la pantalla
	LD DE,(#_posiciones_super_buffer)
bucle_dibujado_fondo:
	;Leo en HL el tile a meter en el superbuffer
	LD L,0 (IX)
	LD H,#0
	ADD HL,HL	;x2
	ADD HL,HL	;x4
	ADD HL,HL	;x8
	ADD HL,HL	;x16
	LD BC,#_tiles
	ADD HL,BC	;hl apunta al tile a transferir
	;me falta conocer el destino. IY apunta al destino
	EX DE,HL
	PUSH HL
	call transferir_map_sbuffer		;DE origen HL destino

; Inicio Mod. 29.06.2009
; Se cambia la forma de controlar el final de datos de tiles. El #0xFF ahora sí que se podrá utilizar.
	ld HL,(#contador_tiles2)
	dec HL
	LD (#contador_tiles2),HL
	LD A,H
	OR L
	jp z, ret2
; Fin    Mod. 29.06.2009
	POP HL
	INC IX	;Siguiente byte

	EX DE,HL
	LD A,(#contador_tiles)
	CP #ancho_pantalla_bytes/2-1 
	JP Z,incremento2
	INC A
	LD (#contador_tiles),A
	INC DE
	INC DE	;para pasar a la siguiente posición
	;si ya se va por el 18 el salto es mayor, es
	JP bucle_dibujado_fondo

incremento2:
	XOR A
	LD (#contador_tiles),A
	LD BC, #7*ancho_pantalla_bytes+2 
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	JP bucle_dibujado_fondo

contador_tiles: .DB 0
contador_tiles2: .DW 0
ntiles: .DW  ( alto_pantalla_bytes / 8 ) * ( ancho_pantalla_bytes / 2	)
ret2:

	pop hl
	ret


transferir_map_sbuffer:

		ld bc,#ancho_pantalla_bytes-1 

		.DB #0xfD
   		LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE

loop_alto_map_sbuffer:
loop_ancho_map_sbuffer:
	ld A,(DE)
	ld (HL),A
	inc de
	inc hl
	ld A,(DE)
	ld (HL),A
	inc de

	.DB #0xfD
	dec h
	ret z
;hay que sumar el ancho de la pantalla en bytes para pasar a la siguiente línea

	add HL,BC
	jp loop_alto_map_sbuffer

.endif	