.module tilemap

.include "tilemap.s"
.include "tilemapC.h"


; Define your tile data at the end of this file


_TileMapConf:


;------------------------------------------------------------------------------------
; Table for the screen position of the tiles (Left Column)
tiles_screen_positions:
.DW #tiles_inipos_visible_area+#0x50*0
.DW #tiles_inipos_visible_area+#0x50*1
.DW #tiles_inipos_visible_area+#0x50*2
.DW #tiles_inipos_visible_area+#0x50*3
.DW #tiles_inipos_visible_area+#0x50*4
.DW #tiles_inipos_visible_area+#0x50*5
.DW #tiles_inipos_visible_area+#0x50*6
.DW #tiles_inipos_visible_area+#0x50*7
.DW #tiles_inipos_visible_area+#0x50*8
.DW #tiles_inipos_visible_area+#0x50*9
.DW #tiles_inipos_visible_area+#0x50*10
.DW #tiles_inipos_visible_area+#0x50*11
.DW #tiles_inipos_visible_area+#0x50*12
.DW #tiles_inipos_visible_area+#0x50*13
.DW #tiles_inipos_visible_area+#0x50*14
.DW #tiles_inipos_visible_area+#0x50*15
.DW #tiles_inipos_visible_area+#0x50*16
.DW #tiles_inipos_visible_area+#0x50*17
.DW #tiles_inipos_visible_area+#0x50*18
.DW #tiles_inipos_visible_area+#0x50*19

;------------------------------------------------------------------------------------
; Table for the Supperbuffer position of the tiles (Left Column)
tiles_composition_buffer:			
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*0
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*1
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*2
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*3
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*4
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*5
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*6
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*7
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*8
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*9
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*10
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*11
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*12
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*13
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*14
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*15
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*16
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*17
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*18
.DW #tiles_composition_buffer_addr+8*tiles_scrwidth_bytes*19


;------------------------------------------------------------------------------------
tiles_current_screen: .DW #0
tiles_game_screen:  ;en tiles
.ds T_WIDTH*T_HEIGHT
.DB #0xFF	;Este byte es importante, marca el fin de la pantalla.
tiles_dirty:		; this table controls the tiles to be redrawn in the screen. 
.ds 150				; It requires 2bytes per tile
;------------------------------------------------------------------------------------
tiles_screen_widths:	; table for internal use to make faster calculations
.dw #tiles_game_screen + #0
.dw #tiles_game_screen + #1*T_WIDTH
.dw #tiles_game_screen + #2*T_WIDTH
.dw #tiles_game_screen + #3*T_WIDTH
.dw #tiles_game_screen + #4*T_WIDTH
.dw #tiles_game_screen + #5*T_WIDTH
.dw #tiles_game_screen + #6*T_WIDTH
.dw #tiles_game_screen + #7*T_WIDTH
.dw #tiles_game_screen + #8*T_WIDTH
.dw #tiles_game_screen + #9*T_WIDTH
.dw #tiles_game_screen + #10*T_WIDTH
.dw #tiles_game_screen + #11*T_WIDTH
.dw #tiles_game_screen + #12*T_WIDTH
.dw #tiles_game_screen + #13*T_WIDTH
.dw #tiles_game_screen + #14*T_WIDTH
.dw #tiles_game_screen + #15*T_WIDTH
.dw #tiles_game_screen + #16*T_WIDTH
.dw #tiles_game_screen + #17*T_WIDTH
.dw #tiles_game_screen + #18*T_WIDTH
.dw #tiles_game_screen + #19*T_WIDTH


;------------------------------------------------------------------------------------
; TILE DATA. TILES MUST BE DEFINED HERE!
;------------------------------------------------------------------------------------

cpc_tiles: ;Son de 2x8 bytes
;tile 0
.db #0x00,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0xC0
.db #0x00,#0x00
;tile 1
.db #0x3C,#0x00
.db #0x3C,#0x00
.db #0x00,#0x3C
.db #0x00,#0x3C
.db #0x3C,#0x00
.db #0x3C,#0x00
.db #0x00,#0x3C
.db #0x00,#0x3C
;tile 2
.db #0x00,#0x00
.db #0x15,#0x00
.db #0x00,#0x2A
.db #0x15,#0x00
.db #0x00,#0x2A
.db #0x15,#0x00
.db #0x00,#0x00
.db #0x00,#0x00

;tile 2
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
.db #0xFF,#0xFF
