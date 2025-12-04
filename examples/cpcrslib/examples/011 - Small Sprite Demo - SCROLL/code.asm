;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.5.2 #9293 (MINGW64)
; This file was generated Tue Sep 15 21:19:29 2015
;--------------------------------------------------------
	.module code
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _act_visible
	.globl _actualizaPantalla
	.globl _print_credits
	.globl _draw_tilemap
	.globl _draw_bloque
	.globl _collide
	.globl _pause
	.globl _set_colours
	.globl _ScrClr
	.globl _setScreen
	.globl _initPointers
	.globl _drawColumnI
	.globl _drawColumnD
	.globl _cpc_ScrollLeft01
	.globl _cpc_ScrollLeft00
	.globl _cpc_ScrollRight01
	.globl _cpc_ScrollRight00
	.globl _cpc_PutMaskSpTileMap2b
	.globl _cpc_UpdScr
	.globl _cpc_PutSpTileMap
	.globl _cpc_ResetTouchedTiles
	.globl _cpc_ShowTileMap2
	.globl _cpc_ShowTileMap
	.globl _cpc_SetTile
	.globl _cpc_TestKey
	.globl _cpc_SetInkGphStr
	.globl _cpc_PrintGphStrXY
	.globl _cpc_DisableFirmware
	.globl _cpc_SetColour
	.globl _cpc_SetMode
	.globl _pointerH
	.globl _p_sprites
	.globl _nPila
	.globl _pilaEnemigos
	.globl _p_disparo
	.globl _p_sprite
	.globl _p_nave
	.globl _colMax
	.globl _col
	.globl _vs2
	.globl _vs1
	.globl _f
	.globl _e
	.globl _d
	.globl _sc
	.globl _sprite02
	.globl _sprite01
	.globl _sprite00
	.globl _nave
	.globl _sprite
	.globl _edisparo
	.globl _disparo
	.globl _TILES_ANCHO_TOT
	.globl _ANCHO_PANTALLA_SC
	.globl _protas1
	.globl _protas0
	.globl _protai0
	.globl _protai
	.globl _prota0
	.globl _prota
	.globl _spnave
	.globl _bloques
	.globl _paleta
	.globl _test_map2
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_disparo::
	.ds 96
_edisparo::
	.ds 96
_sprite::
	.ds 23
_nave::
	.ds 23
_sprite00::
	.ds 23
_sprite01::
	.ds 23
_sprite02::
	.ds 23
_sc::
	.ds 1
_d::
	.ds 1
_e::
	.ds 1
_f::
	.ds 1
_vs1::
	.ds 1
_vs2::
	.ds 1
_col::
	.ds 2
_colMax::
	.ds 2
_p_nave::
	.ds 2
_p_sprite::
	.ds 20
_p_disparo::
	.ds 20
_pilaEnemigos::
	.ds 60
_nPila::
	.ds 1
_p_sprites::
	.ds 14
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_pointerH::
	.ds 2
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;scroll_engine.h:51: void drawColumnD(void)
;	---------------------------------
; Function drawColumnD
; ---------------------------------
_drawColumnD::
;scroll_engine.h:77: __endasm;
	xor a
	ld (paresI),a
	ld hl,(#_pointerH)
	push hl
	bit 0,l
	call nz,setParesI
	ld bc,#28 ; ancho tiles
	add hl,bc
	srl h
	rr l
	ld (#print_tileA+1),hl
	pop hl
	inc hl
	ld (#_pointerH),hl
	ld iy,#datos_scroll_CD ; tiles 1 y 3
	push iy
	push ix
	call vetiles
	pop ix
	pop iy
	ret
_test_map2:
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0E	;  14
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x1C	;  28
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x08	;  8
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x1C	;  28
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x1C	;  28
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x10	;  16
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x11	;  17
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x08	;  8
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x14	;  20
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0F	;  15
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x13	;  19
	.db #0x12	;  18
	.db #0x0B	;  11
	.db #0x0B	;  11
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x14	;  20
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x14	;  20
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x09	;  9
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x14	;  20
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x05	;  5
	.db #0x06	;  6
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x14	;  20
	.db #0x14	;  20
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x08	;  8
	.db #0x09	;  9
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x0A	;  10
	.db #0x0A	;  10
	.db #0x08	;  8
	.db #0x14	;  20
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x08	;  8
	.db #0x07	;  7
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x03	;  3
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x15	;  21
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x06	;  6
	.db #0x06	;  6
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x15	;  21
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x15	;  21
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x04	;  4
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x02	;  2
	.db #0x06	;  6
	.db #0x06	;  6
_paleta:
	.db #0x14	;  20
	.db #0x19	;  25
	.db #0x17	;  23
	.db #0x15	;  21
	.db #0x04	;  4
	.db #0x1C	;  28
	.db #0x0C	;  12
	.db #0x16	;  22
	.db #0x1B	;  27
	.db #0x1F	;  31
	.db #0x0E	;  14
	.db #0x0A	;  10
	.db #0x03	;  3
	.db #0x0F	;  15
	.db #0x00	;  0
	.db #0x0B	;  11
	.db #0x14	;  20
_bloques:
	.db #0x01	;  1
	.db #0x28	;  40
	.db #0x03	;  3
	.db #0x28	;  40
	.db #0x01	;  1
	.db #0x28	;  40
	.db #0x03	;  3
	.db #0x0D	;  13
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x0D	;  13
	.db #0x0D	;  13
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x05	;  5
	.db #0x06	;  6
	.db #0x0D	;  13
	.db #0x0D	;  13
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x05	;  5
	.db #0x06	;  6
	.db #0x00	;  0
	.db #0x01	;  1
	.db #0x02	;  2
	.db #0x03	;  3
	.db #0x29	;  41
	.db #0x29	;  41
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x2A	;  42
	.db #0x29	;  41
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x2A	;  42
	.db #0x2A	;  42
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x29	;  41
	.db #0x2A	;  42
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x2B	;  43
	.db #0x2B	;  43
	.db #0x2B	;  43
	.db #0x2B	;  43
	.db #0x20	;  32
	.db #0x21	;  33
	.db #0x20	;  32
	.db #0x21	;  33
	.db #0x0C	;  12
	.db #0x0C	;  12
	.db #0x28	;  40
	.db #0x28	;  40
	.db #0x2D	;  45
	.db #0x2C	;  44
	.db #0x2F	;  47
	.db #0x2E	;  46
	.db #0x2D	;  45
	.db #0x30	;  48	'0'
	.db #0x2F	;  47
	.db #0x30	;  48	'0'
	.db #0x2B	;  43
	.db #0x2D	;  45
	.db #0x2B	;  43
	.db #0x2F	;  47
	.db #0x2C	;  44
	.db #0x2B	;  43
	.db #0x2E	;  46
	.db #0x2B	;  43
	.db #0x30	;  48	'0'
	.db #0x2C	;  44
	.db #0x30	;  48	'0'
	.db #0x2E	;  46
	.db #0x30	;  48	'0'
	.db #0x30	;  48	'0'
	.db #0x30	;  48	'0'
	.db #0x30	;  48	'0'
	.db #0x31	;  49	'1'
	.db #0x31	;  49	'1'
	.db #0x31	;  49	'1'
	.db #0x31	;  49	'1'
	.db #0x31	;  49	'1'
	.db #0x31	;  49	'1'
	.db #0x0D	;  13
	.db #0x0D	;  13
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
	.db #0x32	;  50	'2'
	.db #0x33	;  51	'3'
	.db #0x35	;  53	'5'
	.db #0x34	;  52	'4'
_spnave:
	.db #0x06	; 6
	.db #0x13	; 19
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x25	; 37
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x4B	; 75	'K'
	.db #0x00	; 0
	.db #0x8D	; 141
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x4B	; 75	'K'
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x05	; 5
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x25	; 37
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0x20	; 32
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0xAA	; 170
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0x20	; 32
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x14	; 20
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x14	; 20
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x3C	; 60
	.db #0x00	; 0
	.db #0x1C	; 28
	.db #0x00	; 0
	.db #0x1C	; 28
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0xAA	; 170
	.db #0x05	; 5
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x25	; 37
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xAA	; 170
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x87	; 135
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x25	; 37
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x4B	; 75	'K'
	.db #0x00	; 0
	.db #0x8D	; 141
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x55	; 85	'U'
	.db #0x20	; 32
	.db #0xFF	; 255
	.db #0x00	; 0
_prota:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xB4	; 180
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA5	; 165
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xAA	; 170
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x3F	; 63
	.db #0x55	; 85	'U'
	.db #0x2A	; 42
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0x50	; 80	'P'
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0x50	; 80	'P'
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
_prota0:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0xB4	; 180
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xAA	; 170
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x15	; 21
	.db #0x55	; 85	'U'
	.db #0x2A	; 42
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0xD8	; 216
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
_protai:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x78	; 120	'x'
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x5A	; 90	'Z'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x3F	; 63
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
_protai0:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0x78	; 120	'x'
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x55	; 85	'U'
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x2A	; 42
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0xE4	; 228
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x50	; 80	'P'
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x55	; 85	'U'
	.db #0x00	; 0
_protas0:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x78	; 120	'x'
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0x00	; 0
	.db #0x5A	; 90	'Z'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0A	; 10
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x3F	; 63
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0F	; 15
	.db #0x55	; 85	'U'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xCC	; 204
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x44	; 68	'D'
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0x00	; 0
	.db #0x88	; 136
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0x00	; 0
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
_protas1:
	.db #0x05	; 5
	.db #0x11	; 17
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x49	; 73	'I'
	.db #0x00	; 0
	.db #0xC3	; 195
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xC3	; 195
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x00	; 0
	.db #0x86	; 134
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x86	; 134
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x86	; 134
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA4	; 164
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAE	; 174
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAE	; 174
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA4	; 164
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAE	; 174
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0x00	; 0
	.db #0x5D	; 93
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA4	; 164
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xA4	; 164
	.db #0x00	; 0
	.db #0x49	; 73	'I'
	.db #0x00	; 0
	.db #0xC3	; 195
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xD2	; 210
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x58	; 88	'X'
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xD2	; 210
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0x49	; 73	'I'
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xC3	; 195
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x04	; 4
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xD7	; 215
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xC3	; 195
	.db #0x55	; 85	'U'
	.db #0x08	; 8
	.db #0xAA	; 170
	.db #0x50	; 80	'P'
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xEB	; 235
	.db #0x00	; 0
	.db #0x86	; 134
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x00	; 0
	.db #0xA4	; 164
	.db #0x00	; 0
	.db #0x0C	; 12
	.db #0x00	; 0
	.db #0x58	; 88	'X'
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0xFF	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xF0	; 240
	.db #0x55	; 85	'U'
	.db #0xA0	; 160
;scroll_engine.h:82: void drawColumnI(void)
;	---------------------------------
; Function drawColumnI
; ---------------------------------
_drawColumnI::
;scroll_engine.h:300: __endasm;
	xor a
	ld (paresI),a
	ld hl,(#_pointerH)
	bit 0,l
	call nz,setParesI
	push hl
	srl h
	rr l
	ld (#print_tileA+1),hl
	pop hl
	dec hl
	ld (#_pointerH),hl
	ld iy,#datos_scroll_CI ; tiles 1 y 3
	push iy
	push ix
	call vetiles
	pop ix
	pop iy
	ret
	vetiles:
; correspendiendo a pantalla juego y superbuffer
	ld a,#7
	bucle_ciA:
	push af
	ld l,0 (iy)
	ld h,1 (iy)
	ld (#tile3A+1),hl
	ld l,4 (iy)
	ld h,5 (iy)
	ld (#tile1A+1),hl
	ld l,2 (iy)
	ld h,3 (iy)
	ld (#tile3deA+1),hl
	ld l,6 (iy)
	ld h,7 (iy)
	ld (#tile1deA+1),hl
	ld l,8 (iy)
	ld h,9 (iy) ; inicio datos en línea pantalla total
	call print_tileA
	ld de,#10
	add iy,de
	pop af
	dec a
	jp nz,bucle_ciA
	ret
	setParesI:
	ld a,#0x23 ; PONER UN inC HL
	ld (#paresI),A
	ret
; HL línea correspondiente a los datos origen del mapa global
; BC tiene el número de columna a buscar
	print_tileA:
	ld bc,#0000
	ld de,#_test_map2
	add hl,de
	add hl,bc
	ld l,(hl) ; bloque
	ld h,#0
	add hl,hl
	add hl,hl
	ld de,#_bloques
	add hl,de ; EN HL están los datos del bloque
	paresI:
	NOP ; INC HL = #0x23
	push hl
	pop ix ; apunta al bloque
	ld a,(hl)
	tile1A:
	ld hl,#0000
	ld (hl),a
;; Y ahora se dibujan esos tiles en el buffer
	tile1deA:
	ld de, #0000
	call dibuja_tile
	tile3A:
	ld hl,#0000
	ld a,2 (ix)
	ld (hl),a
	tile3deA:
	ld de, #0000
; jp dibuja_tile
; ret
	.db #0,#1,#2,#7
	dibuja_tile:
; HL datos tile
; DE destino
; push bc
	ld l,a
	ld h,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL ; X16
	LD bc,#cpc_tiles
	ADD HL,bc
; tiles_composition_buffer + ancho * y + x
	ldi ;5
	ldi ;de<-hl ;5
	ex de,hl ;1
	ld bc,#54 ; ancho - 2 (bytes) ;3
	ld a,c
	add HL,BC ;3
	ex de,hl ;1
	ldi ;5
	ldi ;5
	ex de,hl ;1
	ld c,a ;2
	add HL,BC ;3
	ex de,hl ;1
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ret
	datos_scroll_CD:
	.dw #tiles_game_screen+28*1+26,#0x100+52+56*1*8
	.dw #tiles_game_screen+28*0+26,#0x100+52+56*0*8
	.dw #240*0
	.dw #tiles_game_screen+28*3+26,#0x100+52+56*3*8
	.dw #tiles_game_screen+28*2+26,#0x100+52+56*2*8
	.dw #240*1
	.dw #tiles_game_screen+28*5+26,#0x100+52+56*5*8
	.dw #tiles_game_screen+28*4+26,#0x100+52+56*4*8
	.dw #240*2
	.dw #tiles_game_screen+28*7+26,#0x100+52+56*7*8
	.dw #tiles_game_screen+28*6+26,#0x100+52+56*6*8
	.dw #240*3
	.dw #tiles_game_screen+28*9+26,#0x100+52+56*9*8
	.dw #tiles_game_screen+28*8+26,#0x100+52+56*8*8
	.dw #240*4
	.dw #tiles_game_screen+28*11+26,#0x100+52+56*11*8
	.dw #tiles_game_screen+28*10+26,#0x100+52+56*10*8
	.dw #240*5
	.dw #tiles_game_screen+28*13+26,#0x100+52+56*13*8
	.dw #tiles_game_screen+28*12+26,#0x100+52+56*12*8
	.dw #240*6
	.dw #tiles_game_screen+28*15+26,#0x100+52+56*15*8
	.dw #tiles_game_screen+28*14+26,#0x100+52+56*14*8
	.dw #240*7
	datos_scroll_CI:
	.dw #tiles_game_screen+28*1,#0x100+56*1*8
	.dw #tiles_game_screen+28*0,#0x100+56*0*8
	.dw #240*0
	.dw #tiles_game_screen+28*3,#0x100+56*3*8
	.dw #tiles_game_screen+28*2,#0x100+56*2*8
	.dw #240*1
	.dw #tiles_game_screen+28*5,#0x100+56*5*8
	.dw #tiles_game_screen+28*4,#0x100+56*4*8
	.dw #240*2
	.dw #tiles_game_screen+28*7,#0x100+56*7*8
	.dw #tiles_game_screen+28*6,#0x100+56*6*8
	.dw #240*3
	.dw #tiles_game_screen+28*9,#0x100+56*9*8
	.dw #tiles_game_screen+28*8,#0x100+56*8*8
	.dw #240*4
	.dw #tiles_game_screen+28*11,#0x100+56*11*8
	.dw #tiles_game_screen+28*10,#0x100+56*10*8
	.dw #240*5
	.dw #tiles_game_screen+28*13,#0x100+56*13*8
	.dw #tiles_game_screen+28*12,#0x100+56*12*8
	.dw #240*6
	.dw #tiles_game_screen+28*15,#0x100+56*15*8
	.dw #tiles_game_screen+28*14,#0x100+56*14*8
	.dw #240*7
	ret
;code.c:39: void initPointers()
;	---------------------------------
; Function initPointers
; ---------------------------------
_initPointers::
;code.c:42: p_sprites[0] = &sprite00;
	ld	hl,#_sprite00
	ld	(_p_sprites), hl
;code.c:43: p_sprites[1] = &sprite01;
	ld	hl,#_sprite01
	ld	((_p_sprites + 0x0002)), hl
;code.c:44: p_sprites[2] = &sprite02;
	ld	hl,#_sprite02
	ld	((_p_sprites + 0x0004)), hl
	ret
_ANCHO_PANTALLA_SC:
	.dw #0x0384
_TILES_ANCHO_TOT:
	.db #0xF0	; 240
;code.c:48: void setScreen(void)
;	---------------------------------
; Function setScreen
; ---------------------------------
_setScreen::
;code.c:69: __endasm;
	ld hl,#registros
	xor a
	buc_reg:
	ld b,#0xbc
	ld c,a
	out (c),c
	ld b,#0xbd
	ld c,(hl)
	out (c),c
	inc hl
	inc a
	cp #16
	jr nz,buc_reg
	ret
	registros:
	.db #0x3f,#0x20,#0x2b,#0x8e,#0x26,#0x04,#0x14,#0x1d,#0x00,#0x07,#0x00,#0x00,#0x30,#0x00,#0x00,#0x00
	ret
;code.c:73: void ScrClr(void)
;	---------------------------------
; Function ScrClr
; ---------------------------------
_ScrClr::
;code.c:83: __endasm;
	ld hl,#0xc000
	ld de,#0xc001
	ld bc,#0x3fff
	xor a
	ld (hl),a
	ldir
	ret
;code.c:85: void set_colours(void)
;	---------------------------------
; Function set_colours
; ---------------------------------
_set_colours::
;code.c:88: for (i=0; i<17; i++)
	ld	d,#0x00
00102$:
;code.c:89: cpc_SetColour(i,paleta[i]);
	ld	iy,#_paleta
	ld	c,d
	ld	b,#0x00
	add	iy, bc
	ld	h, 0 (iy)
	push	de
	push	hl
	inc	sp
	push	de
	inc	sp
	call	_cpc_SetColour
	pop	de
;code.c:88: for (i=0; i<17; i++)
	inc	d
	ld	a,d
	sub	a, #0x11
	jr	C,00102$
	ret
;code.c:92: void pause(void)
;	---------------------------------
; Function pause
; ---------------------------------
_pause::
;code.c:99: __endasm;
	ld b,#80
	pause_loop:
	halt
	djnz pause_loop
	ret
;code.c:101: void collide(void)
;	---------------------------------
; Function collide
; ---------------------------------
_collide::
;code.c:103: cpc_SetColour(16,1);
	ld	hl,#0x0110
	push	hl
	call	_cpc_SetColour
;code.c:104: pause();
	call	_pause
;code.c:105: cpc_SetColour(16,9);
	ld	hl,#0x0910
	push	hl
	call	_cpc_SetColour
	ret
;code.c:109: void draw_bloque(unsigned char x, unsigned char y, unsigned char b)
;	---------------------------------
; Function draw_bloque
; ---------------------------------
_draw_bloque::
	push	ix
	ld	ix,#0
	add	ix,sp
;code.c:113: tx = 2*x;
	ld	a,4 (ix)
	add	a, a
	ld	c,a
;code.c:114: ty = 2*y;
	ld	a,5 (ix)
	add	a, a
	ld	b,a
;code.c:115: tb = b*4;
	ld	l,6 (ix)
	ld	h,#0x00
	add	hl, hl
	add	hl, hl
	ex	de,hl
;code.c:117: cpc_SetTile(tx,ty,bloques[tb]);
	ld	hl,#_bloques
	add	hl,de
	ld	h,(hl)
	push	bc
	push	de
	push	hl
	inc	sp
	push	bc
	call	_cpc_SetTile
	pop	af
	inc	sp
	pop	de
	pop	bc
;code.c:118: cpc_SetTile(tx+1,ty,bloques[tb+1]);
	ld	h,e
	inc	h
	ld	a,#<(_bloques)
	add	a, h
	ld	l,a
	ld	a,#>(_bloques)
	adc	a, #0x00
	ld	h,a
	ld	h,(hl)
	ld	d,c
	inc	d
	push	bc
	push	de
	push	hl
	inc	sp
	ld	c, d
	push	bc
	call	_cpc_SetTile
	pop	af
	inc	sp
	pop	de
	pop	bc
;code.c:119: cpc_SetTile(tx,ty+1,bloques[tb+2]);
	ld	l,e
	inc	l
	inc	l
	ld	a,#<(_bloques)
	add	a, l
	ld	l,a
	ld	a,#>(_bloques)
	adc	a, #0x00
	ld	h,a
	ld	h,(hl)
	inc	b
	push	bc
	push	de
	push	hl
	inc	sp
	push	bc
	call	_cpc_SetTile
	pop	af
	inc	sp
	pop	de
	pop	bc
;code.c:120: cpc_SetTile(tx+1,ty+1,bloques[tb+3]);
	inc	e
	inc	e
	inc	e
	ld	a,#<(_bloques)
	add	a, e
	ld	l,a
	ld	a,#>(_bloques)
	adc	a, #0x00
	ld	h,a
	ld	h,(hl)
	push	hl
	inc	sp
	ld	c, d
	push	bc
	call	_cpc_SetTile
	pop	af
	inc	sp
	pop	ix
	ret
;code.c:125: void draw_tilemap(void)
;	---------------------------------
; Function draw_tilemap
; ---------------------------------
_draw_tilemap::
;code.c:130: for(y=0; y<7; y++)
	ld	e,#0x00
;code.c:132: for(x=0; x<14; x++)
00109$:
	ld	d,#0x00
00103$:
;code.c:134: tt=TILES_ANCHO_TOT*y+x;
	ld	hl,#_TILES_ANCHO_TOT + 0
	ld	h, (hl)
	push	de
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00123$:
	add	hl,hl
	jr	NC,00124$
	add	hl,de
00124$:
	djnz	00123$
	pop	de
	ld	c,d
	ld	b,#0x00
	add	hl,bc
;code.c:135: t=test_map2[tt];
	ld	bc,#_test_map2
	add	hl,bc
	ld	h,(hl)
;code.c:136: draw_bloque(x,y,t);
	push	de
	push	hl
	inc	sp
	ld	a,e
	push	af
	inc	sp
	push	de
	inc	sp
	call	_draw_bloque
	pop	af
	inc	sp
	pop	de
;code.c:132: for(x=0; x<14; x++)
	inc	d
	ld	a,d
	sub	a, #0x0E
	jr	C,00103$
;code.c:130: for(y=0; y<7; y++)
	inc	e
	ld	a,e
	sub	a, #0x07
	jr	C,00109$
	ret
;code.c:144: void print_credits(void)
;	---------------------------------
; Function print_credits
; ---------------------------------
_print_credits::
;code.c:147: cpc_PrintGphStrXY("SMALL;SCROLL;SPRITE;DEMO",7*2+2,20*8);
	ld	de,#___str_0
	ld	hl,#0xA010
	push	hl
	push	de
	call	_cpc_PrintGphStrXY
;code.c:148: cpc_PrintGphStrXY("SDCC;;;CPCRSLIB",12*2+1,21*8);
	ld	de,#___str_1
	ld	hl,#0xA819
	push	hl
	push	de
	call	_cpc_PrintGphStrXY
;code.c:149: cpc_PrintGphStrXY("BY;ARTABURU;2015",12*2+1-1,22*8);
	ld	de,#___str_2
	ld	hl,#0xB018
	push	hl
	push	de
	call	_cpc_PrintGphStrXY
;code.c:150: cpc_PrintGphStrXY("ESPSOFT<AMSTRAD<ES",12*2+1-3,24*8);
	ld	de,#___str_3
	ld	hl,#0xC016
	push	hl
	push	de
	call	_cpc_PrintGphStrXY
	ret
___str_0:
	.ascii "SMALL;SCROLL;SPRITE;DEMO"
	.db 0x00
___str_1:
	.ascii "SDCC;;;CPCRSLIB"
	.db 0x00
___str_2:
	.ascii "BY;ARTABURU;2015"
	.db 0x00
___str_3:
	.ascii "ESPSOFT<AMSTRAD<ES"
	.db 0x00
;code.c:158: void actualizaPantalla(void)
;	---------------------------------
; Function actualizaPantalla
; ---------------------------------
_actualizaPantalla::
;code.c:162: cpc_ResetTouchedTiles();
	call	_cpc_ResetTouchedTiles
;code.c:163: switch (sc)
	ld	a,#0x04
	ld	iy,#_sc
	sub	a, 0 (iy)
	jp	C,00146$
	ld	iy,#_sc
	ld	e,0 (iy)
	ld	d,#0x00
	ld	hl,#00237$
	add	hl,de
	add	hl,de
	add	hl,de
	jp	(hl)
00237$:
	jp	00101$
	jp	00108$
	jp	00115$
	jp	00122$
	jp	00135$
;code.c:165: case 0:		
00101$:
;code.c:169: cpc_PutSpTileMap(p_nave);
	ld	hl,(_p_nave)
	call	_cpc_PutSpTileMap
;code.c:170: if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
	ld	hl, #(_sprite00 + 0x000c) + 0
	ld	h,(hl)
	ld	a,h
	dec	a
	jr	Z,00102$
	ld	a,h
	sub	a, #0x02
	jr	NZ,00103$
00102$:
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutSpTileMap
00103$:
;code.c:171: if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
	ld	hl, #(_sprite01 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00105$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00106$
00105$:
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutSpTileMap
00106$:
;code.c:173: cpc_UpdScr();							// restaura los tiles actualizados
	call	_cpc_UpdScr
;code.c:181: break;
	jp	00146$
;code.c:183: case 1:
00108$:
;code.c:185: cpc_ScrollLeft00();		
	call	_cpc_ScrollLeft00
;code.c:190: cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutSpTileMap
;code.c:191: if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
	ld	hl, #(_sprite00 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00109$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00110$
00109$:
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutSpTileMap
00110$:
;code.c:192: if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
	ld	hl, #(_sprite01 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00112$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00113$
00112$:
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutSpTileMap
00113$:
;code.c:194: cpc_UpdScr();							// restaura los tiles actualizados
	call	_cpc_UpdScr
;code.c:205: vs1=1;
	ld	hl,#_vs1 + 0
	ld	(hl), #0x01
;code.c:206: e=1;
	ld	hl,#_e + 0
	ld	(hl), #0x01
;code.c:207: f=0;
	ld	hl,#_f + 0
	ld	(hl), #0x00
;code.c:208: break;
	jp	00146$
;code.c:211: case 2:
00115$:
;code.c:213: cpc_ScrollRight00();
	call	_cpc_ScrollRight00
;code.c:219: cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutSpTileMap
;code.c:220: if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
	ld	hl, #(_sprite00 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00116$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00117$
00116$:
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutSpTileMap
00117$:
;code.c:221: if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
	ld	hl, #(_sprite01 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00119$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00120$
00119$:
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutSpTileMap
00120$:
;code.c:223: cpc_UpdScr();							// restaura los tiles actualizados
	call	_cpc_UpdScr
;code.c:234: vs1=2;
	ld	hl,#_vs1 + 0
	ld	(hl), #0x02
;code.c:235: f=1;
	ld	hl,#_f + 0
	ld	(hl), #0x01
;code.c:236: e=0;
	ld	hl,#_e + 0
	ld	(hl), #0x00
;code.c:238: break;
	jp	00146$
;code.c:239: case 3:											// si ha habido scroll hacia la izquierda
00122$:
;code.c:243: if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
	ld	hl, #(_sprite00 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00123$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00124$
00123$:
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutSpTileMap
00124$:
;code.c:244: if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
	ld	hl, #(_sprite01 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00126$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00127$
00126$:
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutSpTileMap
00127$:
;code.c:246: cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutSpTileMap
;code.c:248: cpc_UpdScr();
	call	_cpc_UpdScr
;code.c:252: if (sprite00.visible==1)
	ld	a, (#(_sprite00 + 0x000c) + 0)
	dec	a
	jr	NZ,00130$
;code.c:254: sprite00.cx-=2;
	ld	hl,#_sprite00 + 8
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
;code.c:255: sprite00.ox-=2;
	ld	hl,#_sprite00 + 10
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
00130$:
;code.c:257: if (sprite01.visible==1)
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jr	NZ,00132$
;code.c:259: sprite01.cx-=2;
	ld	hl,#_sprite01 + 8
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
;code.c:260: sprite01.ox-=2;
	ld	hl,#_sprite01 + 10
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
00132$:
;code.c:265: cpc_ScrollLeft01();						// scroll area tiles
	call	_cpc_ScrollLeft01
;code.c:268: nave.cx-=2;
	ld	hl,#_nave + 8
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
;code.c:269: nave.ox-=2;
	ld	hl,#_nave + 10
	ld	a,(hl)
	add	a,#0xFE
	ld	(hl),a
;code.c:278: drawColumnD();							// actualiza area tiles nueva columna
	call	_drawColumnD
;code.c:280: cpc_PutMaskSpTileMap2b(p_nave);// Ahora se dibuja el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutMaskSpTileMap2b
;code.c:286: vs1=3;
	ld	hl,#_vs1 + 0
	ld	(hl), #0x03
;code.c:287: e=0;
	ld	hl,#_e + 0
	ld	(hl), #0x00
;code.c:288: col+=2;
	ld	hl,#_col
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	adc	a, #0x00
	ld	(hl),a
;code.c:289: if (colMax<col) colMax=col;
	ld	hl,#_col
	ld	a,(#_colMax + 0)
	sub	a, (hl)
	ld	a,(#_colMax + 1)
	inc	hl
	sbc	a, (hl)
	jp	NC,00146$
	ld	hl,(_col)
	ld	(_colMax),hl
;code.c:292: break;
	jp	00146$
;code.c:293: case 4:											// si ha habido scroll hacia la izquierda
00135$:
;code.c:297: if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
	ld	hl, #(_sprite00 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00136$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00137$
00136$:
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutSpTileMap
00137$:
;code.c:298: if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
	ld	hl, #(_sprite01 + 0x000c) + 0
	ld	c,(hl)
	ld	a,c
	dec	a
	jr	Z,00139$
	ld	a,c
	sub	a, #0x02
	jr	NZ,00140$
00139$:
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutSpTileMap
00140$:
;code.c:299: cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutSpTileMap
;code.c:301: cpc_UpdScr();
	call	_cpc_UpdScr
;code.c:303: if (sprite00.visible==1)
	ld	a, (#(_sprite00 + 0x000c) + 0)
	dec	a
	jr	NZ,00143$
;code.c:306: sprite00.cx+=2;
	ld	hl,#_sprite00 + 8
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
;code.c:307: sprite00.ox+=2;
	ld	hl,#_sprite00 + 10
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
00143$:
;code.c:309: if (sprite01.visible==1)
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jr	NZ,00145$
;code.c:312: sprite01.cx+=2;
	ld	hl,#_sprite01 + 8
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
;code.c:313: sprite01.ox+=2;
	ld	hl,#_sprite01 + 10
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
00145$:
;code.c:316: cpc_ScrollRight01();						// scroll area tiles
	call	_cpc_ScrollRight01
;code.c:319: nave.cx+=2;
	ld	hl,#_nave + 8
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
;code.c:320: nave.ox+=2;
	ld	hl,#_nave + 10
	ld	a,(hl)
	add	a, #0x02
	ld	(hl),a
;code.c:327: drawColumnI();							// actualiza area tiles nueva columna
	call	_drawColumnI
;code.c:336: vs1=4;
	ld	hl,#_vs1 + 0
	ld	(hl), #0x04
;code.c:337: f=0;
	ld	hl,#_f + 0
	ld	(hl), #0x00
;code.c:338: col-=2;
	ld	hl,(_col)
	dec	hl
	dec	hl
	ld	(_col),hl
;code.c:341: }
00146$:
;code.c:343: cpc_PutMaskSpTileMap2b(p_nave);// Ahora se dibuja el sprite
	ld	hl,(_p_nave)
	call	_cpc_PutMaskSpTileMap2b
;code.c:344: if (sprite00.visible==1)cpc_PutMaskSpTileMap2b(p_sprites[0]);
	ld	a, (#(_sprite00 + 0x000c) + 0)
	dec	a
	jr	NZ,00148$
	ld	hl, (#_p_sprites + 0)
	call	_cpc_PutMaskSpTileMap2b
00148$:
;code.c:345: if (sprite01.visible==1)cpc_PutMaskSpTileMap2b(p_sprites[1]);
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jr	NZ,00150$
	ld	hl, (#(_p_sprites + 0x0002) + 0)
	call	_cpc_PutMaskSpTileMap2b
00150$:
;code.c:346: cpc_ShowTileMap2();
	call	_cpc_ShowTileMap2
;code.c:351: if (sprite00.visible==2) {
	ld	a, (#(_sprite00 + 0x000c) + 0)
	sub	a, #0x02
	jr	NZ,00152$
;code.c:352: sprite00.visible=3;
	ld	hl,#(_sprite00 + 0x000c)
	ld	(hl),#0x03
00152$:
;code.c:357: if (sprite01.visible==2) {
	ld	a, (#(_sprite01 + 0x000c) + 0)
	sub	a, #0x02
	ret	NZ
;code.c:358: sprite01.visible=3;
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x03
	ret
;code.c:373: void act_visible(void)              // dependiendo del scroll y de la posici�n del sprite, se activa o desactiva
;	---------------------------------
; Function act_visible
; ---------------------------------
_act_visible::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;code.c:377: sprite00.cx=sprite00.vx-2*pointerH;
	ld	de,#_sprite00 + 8
	ld	hl, #_sprite00 + 14
	ld	c,(hl)
	ld	a,(#_pointerH + 0)
	add	a, a
	ld	h,a
	ld	a,c
	sub	a, h
	ld	(de),a
;code.c:378: sprite01.cx=sprite01.vx-2*pointerH;
	ld	hl, #_sprite01 + 14
	ld	c,(hl)
	ld	a,(#_pointerH + 0)
	add	a, a
	ld	h,a
	ld	a,c
	sub	a, h
	ld	hl,#(_sprite01 + 0x0008)
	ld	(hl),a
;code.c:383: if (sprite00.cx>2 && sprite00.cx<50) sprite00.visible = 1; else
	ld	a,(de)
	ld	e,a
	ld	bc,#_sprite00 + 12
;code.c:391: if (sprite01.cx>2 && sprite01.cx<50) sprite01.visible = 1; else
;code.c:380: switch (sc)
	ld	iy,#_sc
	ld	a,0 (iy)
	sub	a, #0x03
	jr	Z,00101$
;code.c:401: if (sprite00.cx>0 && sprite00.cx<48) sprite00.visible = 1; else
	xor	a, a
	sub	a, e
	jp	PO, 00224$
	xor	a, #0x80
00224$:
	rlca
	and	a,#0x01
	ld	-1 (ix),a
;code.c:380: switch (sc)
	ld	iy,#_sc
	ld	a,0 (iy)
	sub	a, #0x04
	jr	Z,00114$
	jp	00127$
;code.c:382: case 3:
00101$:
;code.c:383: if (sprite00.cx>2 && sprite00.cx<50) sprite00.visible = 1; else
	ld	a,#0x02
	sub	a, e
	jp	PO, 00226$
	xor	a, #0x80
00226$:
	jp	P,00105$
	ld	a,e
	xor	a, #0x80
	sub	a, #0xB2
	jr	NC,00105$
	ld	a,#0x01
	ld	(bc),a
	jr	00106$
00105$:
;code.c:385: if (sprite00.visible==1)
	ld	a,(bc)
	dec	a
	jr	NZ,00106$
;code.c:387: sprite00.visible = 2;
	ld	a,#0x02
	ld	(bc),a
00106$:
;code.c:391: if (sprite01.cx>2 && sprite01.cx<50) sprite01.visible = 1; else
	ld	hl, #(_sprite01 + 0x0008) + 0
	ld	h,(hl)
	ld	a,#0x02
	sub	a, h
	jp	PO, 00229$
	xor	a, #0x80
00229$:
	jp	P,00111$
	ld	a,h
	xor	a, #0x80
	sub	a, #0xB2
	jr	NC,00111$
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x01
	jp	00141$
00111$:
;code.c:393: if (sprite01.visible==1)
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jp	NZ,00141$
;code.c:395: sprite01.visible = 2;
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x02
;code.c:399: break;
	jp	00141$
;code.c:400: case 4:
00114$:
;code.c:401: if (sprite00.cx>0 && sprite00.cx<48) sprite00.visible = 1; else
	ld	a,-1 (ix)
	or	a, a
	jr	Z,00118$
	ld	a,e
	xor	a, #0x80
	sub	a, #0xB0
	jr	NC,00118$
	ld	a,#0x01
	ld	(bc),a
	jr	00119$
00118$:
;code.c:403: if (sprite00.visible==1)
	ld	a,(bc)
	dec	a
	jr	NZ,00119$
;code.c:405: sprite00.visible = 2;
	ld	a,#0x02
	ld	(bc),a
00119$:
;code.c:391: if (sprite01.cx>2 && sprite01.cx<50) sprite01.visible = 1; else
	ld	hl, #(_sprite01 + 0x0008) + 0
	ld	h,(hl)
;code.c:409: if (sprite01.cx>2 && sprite01.cx<48) sprite01.visible = 1; else
	ld	a,#0x02
	sub	a, h
	jp	PO, 00234$
	xor	a, #0x80
00234$:
	jp	P,00124$
	ld	a,h
	xor	a, #0x80
	sub	a, #0xB0
	jr	NC,00124$
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x01
	jr	00141$
00124$:
;code.c:411: if (sprite01.visible==1)
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jr	NZ,00141$
;code.c:413: sprite01.visible = 2;
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x02
;code.c:417: break;
	jr	00141$
;code.c:418: default:
00127$:
;code.c:419: if (sprite00.cx>0 && sprite00.cx<50) sprite00.visible = 1; else
	ld	a,-1 (ix)
	or	a, a
	jr	Z,00131$
	ld	a,e
	xor	a, #0x80
	sub	a, #0xB2
	jr	NC,00131$
	ld	a,#0x01
	ld	(bc),a
	jr	00132$
00131$:
;code.c:421: if (sprite00.visible==1)
	ld	a,(bc)
	dec	a
	jr	NZ,00132$
;code.c:423: sprite00.visible = 2;
	ld	a,#0x02
	ld	(bc),a
00132$:
;code.c:391: if (sprite01.cx>2 && sprite01.cx<50) sprite01.visible = 1; else
	ld	hl, #(_sprite01 + 0x0008) + 0
	ld	h,(hl)
;code.c:426: if (sprite01.cx>0 && sprite01.cx<50) sprite01.visible = 1; else
	xor	a, a
	sub	a, h
	jp	PO, 00239$
	xor	a, #0x80
00239$:
	jp	P,00137$
	ld	a,h
	xor	a, #0x80
	sub	a, #0xB2
	jr	NC,00137$
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x01
	jr	00141$
00137$:
;code.c:428: if (sprite01.visible==1)
	ld	a, (#(_sprite01 + 0x000c) + 0)
	dec	a
	jr	NZ,00141$
;code.c:430: sprite01.visible = 2;
	ld	hl,#(_sprite01 + 0x000c)
	ld	(hl),#0x02
;code.c:436: }
00141$:
	inc	sp
	pop	ix
	ret
;code.c:441: main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;code.c:453: cpc_DisableFirmware();
	call	_cpc_DisableFirmware
;code.c:455: cpc_SetMode(0);
	ld	l,#0x00
	call	_cpc_SetMode
;code.c:456: ScrClr();
	call	_ScrClr
;code.c:458: initPointers();
	call	_initPointers
;code.c:460: cpc_SetInkGphStr(0,0);
	ld	hl,#0x0000
	push	hl
	call	_cpc_SetInkGphStr
;code.c:461: cpc_SetInkGphStr(1,2);
	ld	hl,#0x0201
	push	hl
	call	_cpc_SetInkGphStr
;code.c:462: cpc_SetInkGphStr(2,8);
	ld	hl,#0x0802
	push	hl
	call	_cpc_SetInkGphStr
;code.c:463: cpc_SetInkGphStr(3,42);
	ld	hl,#0x2A03
	push	hl
	call	_cpc_SetInkGphStr
;code.c:465: d=0;
	ld	hl,#_d + 0
	ld	(hl), #0x00
;code.c:466: vs1=0;
	ld	hl,#_vs1 + 0
	ld	(hl), #0x00
;code.c:467: vs2=0;
	ld	hl,#_vs2 + 0
	ld	(hl), #0x00
;code.c:468: e=0;
	ld	hl,#_e + 0
	ld	(hl), #0x00
;code.c:469: f=0;
	ld	hl,#_f + 0
	ld	(hl), #0x00
;code.c:470: rt=0;
	ld	-1 (ix),#0x00
;code.c:471: col=0;
	ld	hl,#0x0000
	ld	(_col),hl
;code.c:472: colMax=0;
	ld	l, #0x00
	ld	(_colMax),hl
;code.c:474: p_nave=&nave;
	ld	hl,#_p_nave + 0
	ld	(hl), #<(_nave)
	ld	hl,#_p_nave + 1
	ld	(hl), #>(_nave)
;code.c:475: p_sprites[0] = &sprite00;
	ld	hl,#_sprite00
	ld	(_p_sprites), hl
;code.c:476: p_sprites[1] = &sprite01;
	ld	hl,#_sprite01
	ld	((_p_sprites + 0x0002)), hl
;code.c:478: draw_tilemap();
	call	_draw_tilemap
;code.c:480: print_credits();
	call	_print_credits
;code.c:485: cpc_ShowTileMap();		//Show entire tile map in the screen
	call	_cpc_ShowTileMap
;code.c:486: cpc_ShowTileMap2();
	call	_cpc_ShowTileMap2
;code.c:487: set_colours();
	call	_set_colours
;code.c:490: nave.sp1=prota;
	ld	hl,#_prota
	ld	((_nave + 0x0002)), hl
;code.c:491: nave.sp0=prota;
	ld	(_nave), hl
;code.c:492: nave.ox=12;
	ld	hl,#_nave + 10
	ld	(hl),#0x0C
;code.c:493: nave.oy=87;
	ld	hl,#_nave + 11
	ld	(hl),#0x57
;code.c:494: nave.cx=12;
	ld	hl,#(_nave + 0x0008)
	ld	(hl),#0x0C
;code.c:495: nave.cy=87;
	ld	hl,#_nave + 9
	ld	(hl),#0x57
;code.c:496: nave.visible=3;
	ld	hl,#_nave + 12
	ld	(hl),#0x03
;code.c:497: nave.move=0;
	ld	hl,#(_nave + 0x000d)
	ld	(hl),#0x00
;code.c:498: nave.posicion=0;
	ld	hl,#_nave + 15
	ld	(hl),#0x00
;code.c:499: nave.modo=0;
	ld	hl,#_nave + 16
	ld	(hl),#0x00
;code.c:502: sprite00.sp1=spnave;
	ld	hl,#_spnave
	ld	((_sprite00 + 0x0002)), hl
;code.c:503: sprite00.sp0=spnave;
	ld	(_sprite00), hl
;code.c:504: sprite00.ox=20;
	ld	hl,#_sprite00 + 10
	ld	(hl),#0x14
;code.c:505: sprite00.oy=40;
	ld	hl,#_sprite00 + 11
	ld	(hl),#0x28
;code.c:506: sprite00.cx=20;
	ld	hl,#_sprite00 + 8
	ld	(hl),#0x14
;code.c:507: sprite00.cy=40;
	ld	hl,#_sprite00 + 9
	ld	(hl),#0x28
;code.c:509: sprite00.move=0;
	ld	hl,#(_sprite00 + 0x000d)
	ld	(hl),#0x00
;code.c:510: sprite00.posicion=0;
	ld	hl,#_sprite00 + 15
	ld	(hl),#0x00
;code.c:511: sprite00.visible=0;
	ld	hl,#_sprite00 + 12
	ld	(hl),#0x00
;code.c:512: sprite00.vx=20;
	ld	hl,#(_sprite00 + 0x000e)
	ld	(hl),#0x14
;code.c:513: sprite00.tipo=3;
	ld	hl,#_sprite00 + 18
	ld	(hl),#0x03
;code.c:514: sprite00.frame=0;
	ld	hl,#_sprite00 + 19
	ld	(hl),#0x00
;code.c:515: sprite00.num=1; // num=0 mosca, num=1 rat�n
	ld	hl,#_sprite00 + 20
	ld	(hl),#0x01
;code.c:516: sprite00.dir=0;
	ld	hl,#_sprite00 + 21
	ld	(hl),#0x00
;code.c:518: sprite01.sp1=spnave;
	ld	hl,#_spnave
	ld	((_sprite01 + 0x0002)), hl
;code.c:519: sprite01.sp0=spnave;
	ld	(_sprite01), hl
;code.c:520: sprite01.ox=20;
	ld	hl,#_sprite01 + 10
	ld	(hl),#0x14
;code.c:521: sprite01.oy=45;
	ld	hl,#_sprite01 + 11
	ld	(hl),#0x2D
;code.c:522: sprite01.cx=20;
	ld	hl,#_sprite01 + 8
	ld	(hl),#0x14
;code.c:523: sprite01.cy=45;
	ld	hl,#_sprite01 + 9
	ld	(hl),#0x2D
;code.c:525: sprite01.move=0;
	ld	hl,#(_sprite01 + 0x000d)
	ld	(hl),#0x00
;code.c:526: sprite01.posicion=0;
	ld	hl,#_sprite01 + 15
	ld	(hl),#0x00
;code.c:527: sprite01.visible=0;
	ld	hl,#_sprite01 + 12
	ld	(hl),#0x00
;code.c:528: sprite01.vx=120;
	ld	hl,#(_sprite01 + 0x000e)
	ld	(hl),#0x78
;code.c:529: sprite01.tipo=3;
	ld	hl,#_sprite01 + 18
	ld	(hl),#0x03
;code.c:530: sprite01.frame=0;
	ld	hl,#_sprite01 + 19
	ld	(hl),#0x00
;code.c:531: sprite01.num=1; // num=0 mosca, num=1 rat�n
	ld	hl,#_sprite01 + 20
	ld	(hl),#0x01
;code.c:532: sprite01.dir=0;
	ld	hl,#_sprite01 + 21
	ld	(hl),#0x00
;code.c:536: while(1)
00170$:
;code.c:546: sc=0;
	ld	hl,#_sc + 0
	ld	(hl), #0x00
;code.c:549: if (cpc_TestKey(0)==1 && nave.cx<=40)   // DERECHA
	ld	l,#0x00
	call	_cpc_TestKey
	dec	l
	jr	NZ,00109$
	ld	hl, #(_nave + 0x0008) + 0
	ld	d,(hl)
	ld	a,#0x28
	sub	a, d
	jp	PO, 00320$
	xor	a, #0x80
00320$:
	jp	M,00109$
;code.c:551: nave.cx++;
	inc	d
	ld	hl,#(_nave + 0x0008)
	ld	(hl),d
;code.c:552: nave.move =0;
	ld	hl,#(_nave + 0x000d)
	ld	(hl),#0x00
;code.c:554: if (rt==1)
	ld	a,-1 (ix)
	dec	a
	jr	NZ,00102$
;code.c:556: nave.sp0 = prota;
	ld	hl,#_prota
	ld	(_nave), hl
	jr	00103$
00102$:
;code.c:560: nave.sp0 = prota0;
	ld	hl,#_prota0
	ld	(_nave), hl
00103$:
;code.c:563: rt = !rt;
	ld	a,-1 (ix)
	sub	a,#0x01
	ld	a,#0x00
	rla
	ld	-1 (ix),a
;code.c:565: if (col<ANCHO_PANTALLA_SC)
	ld	de,(_ANCHO_PANTALLA_SC)
	ld	a,(#_col + 0)
	sub	a, e
	ld	a,(#_col + 1)
	sbc	a, d
	jr	NC,00109$
;code.c:568: if (nave.cx>=(40+e))  // se comprueba para ver si hay que hacer scroll al cambiar la direcci�n
	ld	hl, #(_nave + 0x0008) + 0
	ld	d,(hl)
	ld	iy,#_e
	ld	l,0 (iy)
	ld	h,#0x00
	ld	bc,#0x0028
	add	hl,bc
	ld	a,d
	rla
	sbc	a, a
	ld	e,a
	ld	a,d
	sub	a, l
	ld	a,e
	sbc	a, h
	jp	PO, 00323$
	xor	a, #0x80
00323$:
	jp	M,00109$
;code.c:570: vs2=1;
	ld	hl,#_vs2 + 0
	ld	(hl), #0x01
;code.c:571: sc=1;				// SCROLL (<-)
	ld	hl,#_sc + 0
	ld	(hl), #0x01
00109$:
;code.c:576: if (cpc_TestKey(1)==1 && nave.cx>0)   // IZQUIERDA
	ld	l,#0x01
	call	_cpc_TestKey
	dec	l
	jp	NZ,00119$
;code.c:549: if (cpc_TestKey(0)==1 && nave.cx<=40)   // DERECHA
	ld	hl, #(_nave + 0x0008) + 0
	ld	d,(hl)
;code.c:576: if (cpc_TestKey(1)==1 && nave.cx>0)   // IZQUIERDA
	xor	a, a
	sub	a, d
	jp	PO, 00326$
	xor	a, #0x80
00326$:
	jp	P,00119$
;code.c:578: nave.cx--;
	dec	d
	ld	hl,#(_nave + 0x0008)
	ld	(hl),d
;code.c:579: nave.move =1;
	ld	hl,#(_nave + 0x000d)
	ld	(hl),#0x01
;code.c:581: if (rt==1)
	ld	a,-1 (ix)
	dec	a
	jr	NZ,00112$
;code.c:583: nave.sp0 = protai;
	ld	hl,#_protai
	ld	(_nave), hl
	jr	00113$
00112$:
;code.c:587: nave.sp0 = protai0;
	ld	hl,#_protai0
	ld	(_nave), hl
00113$:
;code.c:589: rt = !rt;
	ld	a,-1 (ix)
	sub	a,#0x01
	ld	a,#0x00
	rla
	ld	-1 (ix),a
;code.c:592: if (col>4 )
	ld	a,#0x04
	ld	iy,#_col
	cp	a, 0 (iy)
	ld	a,#0x00
	ld	iy,#_col
	sbc	a, 1 (iy)
	jr	NC,00119$
;code.c:595: if (nave.cx<=(10-f))  // se comprueba para ver si hay que hacer scroll al cambiar la direcci�n
	ld	hl, #(_nave + 0x0008) + 0
	ld	e,(hl)
	ld	iy,#_f
	ld	h,0 (iy)
	ld	l,#0x00
	ld	a,#0x0A
	sub	a, h
	ld	c,a
	ld	a,#0x00
	sbc	a, l
	ld	b,a
	ld	a,e
	rla
	sbc	a, a
	ld	d,a
	ld	a,c
	sub	a, e
	ld	a,b
	sbc	a, d
	jp	PO, 00329$
	xor	a, #0x80
00329$:
	jp	M,00119$
;code.c:597: vs2=2;
	ld	iy,#_vs2
	ld	0 (iy),#0x02
;code.c:598: sc=1;				// SCROLL (->)
	ld	iy,#_sc
	ld	0 (iy),#0x01
00119$:
;code.c:607: if (sc!=0)  	// Tipo de scroll que se realizar� (medio=solo se cambia el punto de lectura de pantalla o total=cambio de coordenadas)
	ld	a,(#_sc + 0)
	or	a, a
	jp	Z,00146$
;code.c:610: if (vs1==1 && vs2==1) sc=3;  // scroll
	ld	a,(#_vs1 + 0)
	dec	a
	jr	NZ,00330$
	ld	a,#0x01
	jr	00331$
00330$:
	xor	a,a
00331$:
	ld	d,a
	or	a, a
	jr	Z,00122$
	ld	a,(#_vs2 + 0)
	dec	a
	jr	NZ,00122$
	ld	iy,#_sc
	ld	0 (iy),#0x03
00122$:
;code.c:611: if (vs1==1 && vs2==2) sc=2;  // 1/2 scroll
	ld	a,d
	or	a, a
	jr	Z,00125$
	ld	a,(#_vs2 + 0)
	sub	a, #0x02
	jr	NZ,00125$
	ld	iy,#_sc
	ld	0 (iy),#0x02
00125$:
;code.c:613: if (vs1==2 && vs2==2) sc=4;  // scroll
	ld	a,(#_vs1 + 0)
	sub	a, #0x02
	jr	NZ,00336$
	ld	a,#0x01
	jr	00337$
00336$:
	xor	a,a
00337$:
	ld	d,a
	or	a, a
	jr	Z,00128$
	ld	a,(#_vs2 + 0)
	sub	a, #0x02
	jr	NZ,00128$
	ld	iy,#_sc
	ld	0 (iy),#0x04
00128$:
;code.c:614: if (vs1==2 && vs2==1) sc=1;  // 1/2 scroll
	ld	a,d
	or	a, a
	jr	Z,00131$
	ld	a,(#_vs2 + 0)
	dec	a
	jr	NZ,00131$
	ld	iy,#_sc
	ld	0 (iy),#0x01
00131$:
;code.c:616: if (vs1==3 && vs2==2) sc=4;  // scroll
	ld	a,(#_vs1 + 0)
	sub	a, #0x03
	jr	NZ,00342$
	ld	a,#0x01
	jr	00343$
00342$:
	xor	a,a
00343$:
	ld	d,a
	or	a, a
	jr	Z,00134$
	ld	a,(#_vs2 + 0)
	sub	a, #0x02
	jr	NZ,00134$
	ld	iy,#_sc
	ld	0 (iy),#0x04
00134$:
;code.c:617: if (vs1==3 && vs2==1) sc=1;  // 1/2 scroll
	ld	a,d
	or	a, a
	jr	Z,00137$
	ld	a,(#_vs2 + 0)
	dec	a
	jr	NZ,00137$
	ld	iy,#_sc
	ld	0 (iy),#0x01
00137$:
;code.c:619: if (vs1==4 && vs2==1) sc=3;  // scroll
	ld	a,(#_vs1 + 0)
	sub	a, #0x04
	jr	NZ,00348$
	ld	a,#0x01
	jr	00349$
00348$:
	xor	a,a
00349$:
	ld	d,a
	or	a, a
	jr	Z,00140$
	ld	a,(#_vs2 + 0)
	dec	a
	jr	NZ,00140$
	ld	iy,#_sc
	ld	0 (iy),#0x03
00140$:
;code.c:620: if (vs1==4 && vs2==2) sc=2;  // 1/2 scroll
	ld	a,d
	or	a, a
	jr	Z,00146$
	ld	a,(#_vs2 + 0)
	sub	a, #0x02
	jr	NZ,00146$
	ld	iy,#_sc
	ld	0 (iy),#0x02
00146$:
;code.c:626: if (sprite00.move==0)   //0 = left, 1 = right
	ld	a, (#(_sprite00 + 0x000d) + 0)
	or	a, a
	jr	NZ,00156$
;code.c:628: if (sprite00.vx>0) sprite00.vx--;
	ld	a, (#(_sprite00 + 0x000e) + 0)
	or	a, a
	jr	Z,00148$
	add	a,#0xFF
	ld	hl,#(_sprite00 + 0x000e)
	ld	(hl),a
	jr	00157$
00148$:
;code.c:629: else sprite00.move=1;
	ld	hl,#(_sprite00 + 0x000d)
	ld	(hl),#0x01
	jr	00157$
00156$:
;code.c:631: if (sprite00.move==1)   //0 = left, 1 = right
	dec	a
	jr	NZ,00157$
;code.c:628: if (sprite00.vx>0) sprite00.vx--;
	ld	hl, #(_sprite00 + 0x000e) + 0
	ld	d,(hl)
;code.c:633: if (sprite00.vx<90) sprite00.vx++;
	ld	a,d
	sub	a, #0x5A
	jr	NC,00151$
	inc	d
	ld	hl,#(_sprite00 + 0x000e)
	ld	(hl),d
	jr	00157$
00151$:
;code.c:634: else sprite00.move=0;
	ld	hl,#(_sprite00 + 0x000d)
	ld	(hl),#0x00
00157$:
;code.c:639: if (sprite01.move==0)   //0 = left, 1 = right
	ld	a, (#(_sprite01 + 0x000d) + 0)
	or	a, a
	jr	NZ,00167$
;code.c:641: if (sprite01.vx>100) sprite01.vx--;
	ld	hl, #(_sprite01 + 0x000e) + 0
	ld	d,(hl)
	ld	a,#0x64
	sub	a, d
	jr	NC,00159$
	dec	d
	ld	hl,#(_sprite01 + 0x000e)
	ld	(hl),d
	jr	00168$
00159$:
;code.c:642: else sprite01.move=1;
	ld	hl,#(_sprite01 + 0x000d)
	ld	(hl),#0x01
	jr	00168$
00167$:
;code.c:644: if (sprite01.move==1)   //0 = left, 1 = right
	dec	a
	jr	NZ,00168$
;code.c:641: if (sprite01.vx>100) sprite01.vx--;
	ld	hl, #(_sprite01 + 0x000e) + 0
	ld	d,(hl)
;code.c:646: if (sprite01.vx<220) sprite01.vx++;
	ld	a,d
	sub	a, #0xDC
	jr	NC,00162$
	inc	d
	ld	hl,#(_sprite01 + 0x000e)
	ld	(hl),d
	jr	00168$
00162$:
;code.c:647: else sprite01.move=0;
	ld	hl,#(_sprite01 + 0x000d)
	ld	(hl),#0x00
00168$:
;code.c:667: act_visible();
	call	_act_visible
;code.c:668: actualizaPantalla();
	call	_actualizaPantalla
	jp	00170$
	inc	sp
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__pointerH:
	.dw #0x0000
	.area _CABS (ABS)
