.module tilemap

.include "TileMap.s"
.include "TileMapC.h"

.globl _cpc_ShowTileMap2

_cpc_ShowTileMap2::

push ix
call rutina
pop ix
ret


.ifeq T_WH + T_HH

rutina:
	ld bc, #256*(ancho_pantalla_bytes-4*(tiles_ocultos_ancho0))+#alto_pantalla_bytes-16*(tiles_ocultos_alto0)

posicion_inicio_pantalla_visible:
	ld hl,#0000


posicion_inicio_pantalla_visible_sb:
	ld hl,#0000
papa:		; código de Xilen Wars
	di
	ld	(#auxsp),sp
	ld	sp,#tablascan
	ld	a,#alto_pantalla_bytes
ppv0:
	pop	de		; va recogiendo de la pila!!
inicio_salto_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi

	ldi
	ldi
	ldi
	ldi


	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
CONT_salto_ldi:

	dec a
	jp nz, ppv0
	ld	sp,(#auxsp)
	ei
	ret

auxsp:	.DW	0





creascanes:
	ld	ix,#tablascan
posicion_inicio_pantalla_visible2:
	ld	hl,#0000
	ld	b, #alto_pantalla_bytes/8	; num de filas.
cts0:
	push	bc
	push	hl
	ld	b,#8
	ld	de,#2048
cts1:
	ld	0 (ix),l
	inc	ix
	ld	0 (ix),h
	inc	ix
	add	hl,de
	djnz	cts1
	pop	hl
	ld	bc,#80
	add	hl,bc
	pop	bc
	djnz	cts0
;	jp prepara_salto_ldi
prepara_salto_ldi:		; para el ancho visible de la pantalla:
	ld hl,#ancho_pantalla_bytes
	ld de,#inicio_salto_ldi
	add hl,hl
	add hl,de
	ld (hl),#0xc3
	inc hl
	ld de,#CONT_salto_ldi
	ld (hl),e
	inc hl
	ld (hl),d
	ret
	
	
.else


rutina:
	ld bc, #256*(ancho_pantalla_bytes-4*(tiles_ocultos_ancho0))+#alto_pantalla_bytes-16*(tiles_ocultos_alto0)

posicion_inicio_pantalla_visible:
	ld hl,#0000


posicion_inicio_pantalla_visible_sb:
	ld hl,#0000
papa:		; código de Xilen Wars
	di
	ld	(#auxsp),sp
	ld	sp,#tablascan
	ld	a,#alto_pantalla_bytes-16*(tiles_ocultos_alto0)	;16 alto
ppv0:
	pop	de		; va recogiendo de la pila!!
inicio_salto_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi

	ldi
	ldi
	ldi
	ldi


	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
CONT_salto_ldi:
	ld	de,#4*tiles_ocultos_ancho0
	add	hl,de

CONT_salto_ldi1:
	dec a
	jp nz, ppv0
	ld	sp,(#auxsp)
	ei
	ret

auxsp:	.DW	0





creascanes:
	ld	ix,#tablascan
posicion_inicio_pantalla_visible2:
	ld	hl,#0000
	ld	b, #alto_pantalla_bytes/8-2*tiles_ocultos_alto0 ; 20	; num de filas.
cts0:
	push	bc
	push	hl
	ld	b,#8
	ld	de,#2048
cts1:
	ld	0 (ix),l
	inc	ix
	ld	0 (ix),h
	inc	ix
	add	hl,de
	djnz	cts1
	pop	hl
	ld	bc,#80
	add	hl,bc
	pop	bc
	djnz	cts0
;	jp prepara_salto_ldi
prepara_salto_ldi:		; para el ancho visible de la pantalla:
	ld hl,#ancho_pantalla_bytes-4*tiles_ocultos_ancho0
	ld de,#inicio_salto_ldi
	add hl,hl
	add hl,de
	ld (hl),#0xc3
	inc hl
	ld de,#CONT_salto_ldi
	ld (hl),e
	inc hl
	ld (hl),d
	ret



.endif

tablascan:	;defs 20*16
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	