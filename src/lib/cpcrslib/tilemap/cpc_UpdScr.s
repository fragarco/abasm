.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_UpdScr

_cpc_UpdScr::

push ix
call rutina

pop ix
ret

rutina:
;lee la tabla de tiles tocados y va restaurando cada uno en su sitio.
	LD IX,#_tiles_tocados							;4
bucle_cpc_UpdScr:
	LD E, 0 (IX)									;5
	LD A,#0xFF										;2
	CP E											;1
	RET Z		;RETORNA SI NO HAY MÁS DATOS EN LA LISTA	;2/4
	LD D,1 (IX)										;5
	INC IX											;3
	INC IX											;3

posicionar_superbuffer:
;con la coordenada y nos situamos en la posición vertical y con x nos movemos a su sitio definitivo
	LD C,D
	SLA C  ;x2
	LD B,#0
	
	; puedo usar BC para el siguiente cálculo
	push bc
	
	LD HL,#_posiciones_super_buffer
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)

	LD L,E
	SLA L
	LD H,#0

	ADD HL,BC
	
	pop bc
		;HL apunta a la posición correspondiente en superbuffer
	push hl

posicionar_tile:

	LD HL,#_tabla_y_ancho_pantalla
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)
	LD L,E
	LD H,#0
	ADD HL,BC
;	LD DE,#_pantalla_juego
;	ADD HL,DE
	LD L,(HL) 
;	xor a
;	cp l
;	jp z, _solo_tile0
	
	LD H,#0
	
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;X16
	LD DE,#_tiles
	ADD HL,DE
	;HL apunta a los datos del tile
;_saltate:
	;ex de,hl
	pop de ;hl
	;RET



;	de: Posición buffer
;	hl: datos tile


transferir_map_sbuffer1:	;; ENVIA EL TILE AL SUPERBUFFER
	;ld bc,ancho_pantalla_bytes-2 ;63
	ldi									;5
	ldi		;de<-hl						;5
	ex de,hl							;1
	ld bc,#ancho_pantalla_bytes-2		;3
	ld a,c
	add HL,BC							;3
	ex de,hl							;1
	ldi									;5
	ldi									;5
	ex de,hl							;1
	ld c,a		;ld c,#ancho_pantalla_bytes-2		;2
	add HL,BC							;3
	ex de,hl							;1
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
jp bucle_cpc_UpdScr	