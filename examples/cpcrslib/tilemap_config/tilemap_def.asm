; Code adapted to ABASM syntax by Javier "Dwayne Hicks" Garcia
; Based on CPCRSLIB:
; Copyright (c) 2008-2015 Raúl Simarro <artaburu@hotmail.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of
; this software and associated documentation files (the "Software"), to deal in the
; Software without restriction, including without limitation the rights to use, copy,
; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so, subject to the
; following conditions:
;
; The above copyright notice and this permission notice shall be included in all copies
; or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
; FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.

; Define your tile data at the end of this file

;----------------------------------------------------------------------------------------
; SCREEN AND BUFFER ADDRESSES
;----------------------------------------------------------------------------------------

tiles_inipos_visible_area      equ &C0A4    ; Top-Left screen value. Where Tile Map is drawn.
tiles_composition_buffer_addr  equ &0100	; Memory location where the superbuffer starts. 
											; superbuffer size= T_WIDTH * 2 + T_HEIGHT * 8

;----------------------------------------------------------------------------------------
; TILE MAP DIMENSIONS
;----------------------------------------------------------------------------------------

T_WIDTH  equ 32 	; Width of screen in Tiles. Max = 40
T_HEIGHT equ 16		; Heigh of screen in Tiles. Max = 20

; Invisible tile margins (in tiles). 
; This area is not shown on the screen. It can be used to make the sprites appear or disappear
; of the screen.

T_WH equ 2			; Number of vertical hidden tiles 		
T_HH equ 0			; Number of horizontal hidden tiles 

;----------------------------------------------------------------------------------------
; Transparent colour for cpc_PutTrSpTileMap2b routine
; for printing sprites using transparent color (mode 0) transparent color selection is 
; requiered. Both masks are required.
;----------------------------------------------------------------------------------------
; Example colour number 7:
; mask1	= 	&54 
; mask2	= 	&A8
;
; 0:  &00, &00
; 1:  &80, &40
; 2:  &04, &08
; 3:  &44, &88
; 4:  &10, &20
; 5:  &50, &A0
; 6:  &14, &28
; 7:  &54, &A8
; 8:  &01, &02
; 9:  &41, &82
; 10: &05, &0A
; 11: &45, &8A
; 12: &11, &22
; 13: &51, &A2
; 14: &15, &2A
; 15: &55, &AA

tiles_mask1 equ 0
tiles_mask2 equ 0

;----------------------------------------------------------------------------------------
; Other parameters (internal use)
;----------------------------------------------------------------------------------------

tiles_hidden_width0     equ T_WH
tiles_hidden_height0    equ T_HH
tiles_hidden_width1     equ T_WIDTH - T_WH - 1
tiles_hidden_height1    equ T_HEIGHT - T_HH - 1
tiles_scrwidth_bytes    equ 2 * T_WIDTH 	
tiles_scrheight_bytes   equ 8 * T_HEIGHT
tiles_scrwidth_visible_bytes equ 2 * T_WIDTH 

;------------------------------------------------------------------------------------
; Table for the screen position of the tiles (Left Column)
;------------------------------------------------------------------------------------

tiles_screen_positions:
    dw tiles_inipos_visible_area + &50 * 0
    dw tiles_inipos_visible_area + &50 * 1
    dw tiles_inipos_visible_area + &50 * 2
    dw tiles_inipos_visible_area + &50 * 3
    dw tiles_inipos_visible_area + &50 * 4
    dw tiles_inipos_visible_area + &50 * 5
    dw tiles_inipos_visible_area + &50 * 6
    dw tiles_inipos_visible_area + &50 * 7
    dw tiles_inipos_visible_area + &50 * 8
    dw tiles_inipos_visible_area + &50 * 9
    dw tiles_inipos_visible_area + &50 * 10
    dw tiles_inipos_visible_area + &50 * 11
    dw tiles_inipos_visible_area + &50 * 12
    dw tiles_inipos_visible_area + &50 * 13
    dw tiles_inipos_visible_area + &50 * 14
    dw tiles_inipos_visible_area + &50 * 15
    dw tiles_inipos_visible_area + &50 * 16
    dw tiles_inipos_visible_area + &50 * 17
    dw tiles_inipos_visible_area + &50 * 18
    dw tiles_inipos_visible_area + &50 * 19

;------------------------------------------------------------------------------------
; Table for the Supperbuffer position of the tiles (Left Column)
;------------------------------------------------------------------------------------

tiles_composition_buffer:			
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 0
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 1
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 2
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 3
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 4
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 5
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 6
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 7
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 8
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 9
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 10
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 11
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 12
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 13
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 14
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 15
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 16
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 17
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 18
    dw tiles_composition_buffer_addr + 8 * tiles_scrwidth_bytes * 19

;------------------------------------------------------------------------------------

tiles_current_screen:  dw 0
tiles_game_screen:
    defs T_WIDTH * T_HEIGHT
    db   &FF	    ; Este byte es importante, marca el fin de la pantalla.
tiles_dirty:	    ; This table controls the tiles to be redrawn in the screen.
    defs 150	    ; It requires 2 bytes per tile

;------------------------------------------------------------------------------------

tiles_screen_widths:	; lookup table to speed up calculations
    dw tiles_game_screen + 0
    dw tiles_game_screen + 1 * T_WIDTH
    dw tiles_game_screen + 2 * T_WIDTH
    dw tiles_game_screen + 3 * T_WIDTH
    dw tiles_game_screen + 4 * T_WIDTH
    dw tiles_game_screen + 5 * T_WIDTH
    dw tiles_game_screen + 6 * T_WIDTH
    dw tiles_game_screen + 7 * T_WIDTH
    dw tiles_game_screen + 8 * T_WIDTH
    dw tiles_game_screen + 9 * T_WIDTH
    dw tiles_game_screen + 10 * T_WIDTH
    dw tiles_game_screen + 11 * T_WIDTH
    dw tiles_game_screen + 12 * T_WIDTH
    dw tiles_game_screen + 13 * T_WIDTH
    dw tiles_game_screen + 14 * T_WIDTH
    dw tiles_game_screen + 15 * T_WIDTH
    dw tiles_game_screen + 16 * T_WIDTH
    dw tiles_game_screen + 17 * T_WIDTH
    dw tiles_game_screen + 18 * T_WIDTH
    dw tiles_game_screen + 19 * T_WIDTH

;------------------------------------------------------------------------------------
; TILE DATA. TILES MUST BE DEFINED HERE!
;------------------------------------------------------------------------------------

cpc_tiles: ; Each tile is 2 x 8 bytes
; tile 0
    db &00,&00
    db &40,&00
    db &40,&00
    db &40,&00
    db &40,&00
    db &40,&00
    db &40,&C0
    db &00,&00
; tile 1
    db &3C,&00
    db &3C,&00
    db &00,&3C
    db &00,&3C
    db &3C,&00
    db &3C,&00
    db &00,&3C
    db &00,&3C
;tile 2
    db &00,&00
    db &15,&00
    db &00,&2A
    db &15,&00
    db &00,&2A
    db &15,&00
    db &00,&00
    db &00,&00
; tile 3
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
    db &FF,&FF
