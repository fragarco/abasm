.module tilemap

; CONSTANT VALUES FOR TILEMAP


;------------------------------------------------------------------------------------------------------------
; SCREEN AND BUFFER ADDRESSES
; VALORES QUE DEFINEN EL BUFFER Y LA PANTALLA
;------------------------------------------------------------------------------------------------------------

tiles_inipos_visible_area = #0xc0AC		; Top-Left screen value. Where Tile Map is drawn.
tiles_composition_buffer_addr  = #0x100		; Memory location where the superbuffer starts. 
											; superbuffer size= T_WIDTH * 2 + T_HEIGHT *8


;------------------------------------------------------------------------------------------------------------
; TILE MAP DIMENSIONS
;------------------------------------------------------------------------------------------------------------

T_WIDTH = 28 			; Width of screen in Tiles. Max = 40
T_HEIGHT = 14			; Heigh of screen in Tiles. Max = 20

; Invisible tile margins (in tiles). 
; This area is not shown on the screen. It can be used to make the sprites appear or disappear of the screen.

T_WH = 2					; Number of vertical hidden tiles 		
T_HH = 0					; Number of horizontal hidden tiles 



;------------------------------------------------------------------------------------------------------------
; Transparent colour for cpc_PutTrSpTileMap2b routine
; for printing sprites using transparent color (mode 0) transparent color selection is requiered. 
; Both masks are required.
;------------------------------------------------------------------------------------------------------------
; Example colour number 7:
; tiles_mask1 	= 	#0x54 
; tiles_mask2 	= 	#0xA8
;
; 0: #0x00, #0x00
; 1: #0x80, #0x40
; 2: #0x04, #0x08
; 3: #0x44, #0x88
; 4: #0x10, #0x20
; 5: #0x50, #0xA0
; 6: #0x14, #0x28
; 7: #0x54, #0xA8
; 8: #0x01, #0x02
; 9: #0x41, #0x82
; 10: #0x05, #0x0A
; 11: #0x45, #0x8A
; 12: #0x11, #0x22
; 13: #0x51, #0xA2
; 14: #0x15, #0x2A
; 15: #0x55, #0xAA

tiles_mask1 	= 	#0
tiles_mask2 	= 	#0




;------------------------------------------------------------------------------------------------------------
; Other parameters (internal use)
;------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------


tiles_hidden_width0 = T_WH
tiles_hidden_height0 = T_HH
tiles_hidden_width1 = T_WIDTH - T_WH - 1
tiles_hidden_height1 = T_HEIGHT - T_HH - 1

tiles_scrwidth_bytes = 2*T_WIDTH 	
							
tiles_scrheight_bytes = 8*T_HEIGHT
tiles_scrwidth_visible_bytes = 2*T_WIDTH 

