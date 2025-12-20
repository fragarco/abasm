;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2016 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

;; Code modified to be used with ABASM by Javier "Dwayne Hicks" Garcia

org &2000
jp  main

;; Code modified to be used with ABASM by Javier "Dwayne Hicks" Garcia

;; Include macros to easily manage undocumented opcodes
;; macros must be declared before their first use
read "cpctelera/macros/cpct_undocumentedOpcodes.asm"

;;===============================================================================
;; DEFINED CONSTANTS
;;===============================================================================

pvideomem      equ &C000  ;; First byte of video memory
pbackbuffer    equ &8000  ;; First byte of the hardware backbuffer
palete_size    equ 4      ;; Number of total palette colours
border_colour  equ &0010  ;; &10 (Border ID), &00 (Colour to set: White).
screen_Width   equ &50    ;; Width of the screen in bytes (80 bytes, &50)
tile_HxW       equ &3214  ;; Height (50 pixels or bytes,  &32) 
                          ;; Width  (80 pixels, 20 bytes, &14) 1 byte = 4 pixels
knight_WxH     equ &9119  ;; Height (145 pixels or bytes,  &91) 
knight_Width   equ &19    ;; Width  (100 pixels, 25 bytes, &19) 1 byte = 4 pixels
knight_offset  equ &39E0  ;; Offset for location (0,55) with respect to screen (0,0)

;; Location offsets for background tiles
;;    There are 16 background tiles, each one taking 8&50 pixels. As tiles
;; will always be at the same place with respect to the origin og the background
;; (coordinate (0,0), top-left corner of the background), we can pre-calculate
;; their offset in bytes with respect to the origin. Next array contains the
;; pre-calculated 16 offsets, which will let easily draw the background by
;; taking each tile and drawing it at origin + offset.
bg_tile_offsets:
;; COLUMN |   0   |  80   |  160  |  240  |   ROW
;;--------------------------------------------------
       dw &0000, &0014, &0028, &003C  ;;   0
       dw &11E0, &11F4, &1208, &121C  ;;  50
       dw &23C0, &23D4, &23E8, &23FC  ;; 100
       dw &35A0, &35B4, &35C8, &35DC  ;; 150
;;--------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNC: initialize
;;    Sets CPC to its initial status
;; DESTROYS:
;;    AF, BC, DE, HL
;;
initialize:
   ;; Disable Firmware
   call  cpct_disableFirmware   ;; Disable firmware

   ;; Set Mode 1
   ld    c, 1                   ;; C = 1 (New video mode)
   call  cpct_setVideoMode      ;; Set Mode 1
   
   ;; Set Palette
   ld    hl, g_palette          ;; HL = pointer to the start of the palette array
   ld    de, palete_size        ;; DE = Size of the palette array (num of colours)
   call  cpct_setPalette        ;; Set the new palette

   ;; Change border colour
   ld    hl, border_colour      ;; L=Border colour value, H=Palette Colour to be set (Border=16)
   call  cpct_setPALColour      ;; Set the border (colour 16)

   ret                          ;; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNC: drawBackgroundTiles
;;    Draws as many background tiles as the number in IXL, picking their offsets
;; from the offset vector provided in HL, and the pointers to the tiles from 
;; the tile vector provided in BC. All tiles will be drawn one by one, in order.
;; 
;; INPUT:
;;    HL: Pointer to the offsets vector (to place tiles in video memory)
;;    DE: Pointer to the place in video memory where background is to be drawn
;;    BC: Pointer to the tiles that will be drawn
;;    IXL:Number of tiles to draw
;;    
;; DESTROYS:
;;    AF, BC, HL, IXL
;;
drawBackgroundTiles:

next_tile:
   push  de       ;; Save DE (Pointer to the origin of the background (0,0) coordinates)

   ;; Make DE Point to the place where the next tile is to be drawn, that is
   ;;   DE += (HL), as DE points to the origin (0,0) of the background and HL points
   ;; to the Offset to be added to point to the place where the tile should be drawn
   ld     a, e    ;; | E += (HL) as HL points to the Least Significant Byte of
   add  (hl)      ;; |  the offset to be added to DE (remember that Z80 is little endian)
   ld     e, a    ;; |
   
   inc   hl       ;; HL++, HL points now to the Most Significant Byte of the offset value

   ld     a, d    ;; | D += (HL) + Carry, as HL points to the MSB of the offset and
   adc  (hl)      ;; |   Carry contains the carry of the last E += (HL) operation.
   ld     d, a    ;; |

   ;; Make HL point to the offset for the next tile to be drawn, then save it
   inc   hl       ;; HL++, so HL points to the LSB of the offset for the next tile to be drawn
   push  hl       ;; Save HL in the stack to recover it for next loop iteration

   ;; Now that DE points to the place in video memory where the tile should be drawn,
   ;; make HL point to the sprite (the tile) that should be drawn there. Get that 
   ;; pointer from (BC), that points to the next element in the g_tileset array, that is,
   ;; the next sprite (tile) to be drawn
   ld     a, (bc) ;; A = LSB from the pointer to the next tile to be drawn
   ld     l, a    ;; L = A = LSB
   inc   bc       ;; BC++, so that BC points to the MSB of the next tile to be drawn
   ld     a, (bc) ;; A = MSB from the pointer to the next tile to be drawn
   ld     h, a    ;; H = A = MSB (Now HL Points to the next tile to be drawn)

   ;; Make BC point to the pointer to the next sprite (tile) to be drawn and save it
   inc   bc       ;; BC++, so that it points to the LSB of the next sprite (tile) in the g_tileset
   push  bc       ;; Save BC in the stack to recover it for next loop iteration

   ;; Draw the tile.
   ;; HL already points to the sprite
   ;; DE already points to the memory location where to draw it
   ld    bc, tile_HxW           ;; BC = Sprite WidthxHeight
   call  cpct_drawSprite        ;; Draw the sprite on the screen

   ;; Recover saved values for next iteration from the stack
   pop   bc       ;; BC points to the pointer to the next sprite (tile) to be drawn
   pop   hl       ;; HL points to the offset with respect to (0,0) where next tile should be drawn
   pop   de       ;; DE points to the origin (0,0) in video memory where background is being drawn

   dec__ixl         ;; IXL--, one less tile to be drawn
   jr nz, next_tile ;; If IXL!=0, there are still some tiles to be drawn, so continue

   ret              ;; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNC: switch_screen_buffer
;;    Switches between front buffer and backbuffer.
;;
;; DESTROYS:
;;    AF, BC, HL
;;

screen_buffer: db (pbackbuffer >> 8) & 0xFF  ;; This variable holds the upper byte of the memory address of the screen backbuffer 
                                             ;; It changes every time buffers are switched, so it always contains backbuffer address.
switch_screen_buffer:
   ;; Check which one of the buffers is actually tagged as backbuffer (&C000 or &8000)
   ld   hl, screen_buffer    ;; HL points to the variable holding actual backbuffer address Most Significant Byte 
   ld    a, (hl)             ;; A = backbuffer address MSB (&C0 or &80)
   cp  &C0                   ;; Check if it is &C00
   jr    z, to_back_buffer   ;; If it is &C000, set it to &8000

to_front_buffer:
   ;; Actual backbuffer is &8000. Switch to &C000
   ld (hl), (pvideomem >> 8) & 0xFF ;; Save &C0 as new backbuffer address MSB
   ld    l, &20                     ;; | Then show new frontbuffer (&8000) 
   call  cpct_setVideoMemoryPage    ;; | ... in the screen
   
   ret                        ;; And Return

to_back_buffer:
   ;; Actual backbuffer is &C000. Switch to &8000
   ld (hl), (pbackbuffer >> 8) & 0xFF ;; Save &80 as new backbuffer address MSB
   ld    l, &30                       ;; | Then show new frontbuffer (&8000) 
   call  cpct_setVideoMemoryPage      ;; | ... in the screen

   ret                        ;; And Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNC: redrawKnight
;;    Erases previous location of the Knight by repainting tiles 4-15 (3 down
;; lines of the screen), then draws the knight again over clear background
;; 
;; INPUTS:
;;    DE: Pointer to the start of video memory buffer where the knight will be drawn
;; 
;; DESTROYS:
;;    AF, BC, DE, HL
;;
knight_x:      db 00   ;; Column where the knight is actually located
knight_dir:    db 00   ;; Direction towards the knight is looking at (0: right, 1: left)

redrawKnight:
   omitted equ 4*2     ;; To draw tiles 4-15 we must omit 4 of them. As each pointer takes 2 bytes, 
                       ;; ... we need to advance 4*2 bytes in the array to reach tile 4.

   ;; Erase previous sprite drawing 3 down rows of tiles
   ld__ixl 12                           ;; IXL=12, as we want to paint 12 tiles (4-15)
   ld    hl, bg_tile_offsets + omitted  ;; HL points to the offset of tile 4, the first one to be drawn
   ld    bc, g_tileset + omitted       ;; BC points to the sprite of tile 4
   call  drawBackgroundTiles             ;; Draw the 12 tiles of the 3 down rows to erase previous sprite

   ;; Calculate location of the knight at the screen
   ;; (DE already points to the start of video memory buffer)
   ld    hl, knight_offset         ;; HL holds the offset of the location (0,Knight_Y) with respect to the start of video memory
   add   hl, de                     ;; HL += DE. HL know points to (0,Y) location in the video memory buffer
   ld     a, (knight_x)             ;; A = Knight_X (Column where the knight is located)
   add    l                         ;; | HL += A  (HL += Knight_X)
   ld     l, a                      ;; |    To make HL point to (X,Y) location in the video memory buffer
   adc    h                         ;; |
   sub    l                         ;; |
   ld     h, a                      ;; |
   ex    de, hl                     ;; DE Points to (X,Y) location in the video memory buffer, where Knight will be drawn
   ld    hl, g_spr_knight         ;; HL Points to the sprite of the knight with interlaced mask
   ld    bc, knight_WxH            ;; BC Holds dimensions of the knight (HxW)
   call  cpct_drawSpriteMasked  ;; Draw the sprite of the knight in the video memory buffer

   ret         ;; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNC: moveKnight
;;    Moves the knight till the end of the screen, makes it turn, returns back
;; and repeats
;; 
;; DESTROYS:
;;    AF, BC, HL
;;
moveKnight:
   ld     a, (knight_dir)     ;; A = Direction towards the knight is looking at (0: right, 1: left)
   dec    a                   ;; A-- (to check which one is the actual direction)
   ld     a, (knight_x)       ;; A = Knight_X (Present column of the knight, that must be updated)
   jr     z, move_left        ;; If Zero, then Knight_dir was 1, so it is looking to the left (jump)
                              ;; ... else it is looking to the right (continue)
move_right:
   inc    a                        ;; A++, to move knight to the right
   ld (knight_x), a                ;; Store new location of the knight
   cp screen_Width - knight_Width  ;; Check if the Knight has arrived to the right border of the screen
   jr     z, turn_around           ;; If Zero, night has arrived to the right border, jump to turn_around section
   ret                             ;; Else, nothing more to do, so return.

move_left:
   dec    a                        ;; A--, to move knight to the left
   ld (knight_x), a                ;; Store new location of the knight
   or     a                        ;; Check present value of A to know if it is 0 or not
   ret   nz                        ;; If A wasn't 0, left limit has not been reached by the knight, so return
                                   ;; Else (A=0), knight is at left limit, so continue to turn it around

turn_around:
   ld    a, (knight_dir)           ;; A=Direction towards the knight is looking at (0: right, 1:left)
   xor   1                         ;; Change direction by altering the Least Significant Bit (0->1, 1->0)
   ld    (knight_dir), a           ;; Store new direction in knight_dir variable
   ld    bc, knight_WxH            ;; BC=Dimensions of the knight sprite
   ld    hl, g_spr_knight          ;; HL=Pointer to the start of the knight sprite
   call  cpct_hflipSpriteMaskedM1  ;; Horizontally flip the knight sprite, along with its mask

   ret      ;; Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN function. This is the entry point of the application.
;;    _main:: global symbol is required for correctly compiling and linking
;;
main: 
   ;; First of all, move Stack Pointer (SP) out of the video memory buffers we want
   ;; to use. By default, it is placed at &C000 and stack grows backwards. As we
   ;; want to use &8000-&BFFF and &C000-&FFFF as video memory buffers, stack must
   ;; be moved to other place. We will place it at &8000, knowing that it grows backwards.
   ld    sp, &8000           ;; Move stack pointer to &8000, outside video memory buffers

   ;; Initialize the CPC (Stack initialization cannot be inside this function, 
   ;; as return address for a call is stored in the stack and changing stack
   ;; location inside the function will make us return to a random place on RET)
   call  initialize            ;; Call to CPC initialization function

   ;; Draw first tile row in the main video memory buffer (&C000-&FFFF)
   ;; (We don't need to draw the other 3 rows, as they will be drawn by redrawKnight function)
   ld__ixl 4                  ;; IXL will act as counter for the number of tiles
   ld    hl, bg_tile_offsets   ;; HL points to the start of the memory offsets for tiles
   ld    bc, g_tileset         ;; BC points to the start of the tileset
   ld    de, pvideomem         ;; DE points to the start of video memory, where Background should be drawn
   call  drawBackgroundTiles   ;; Draw the background

   ;; Draw first tile row in the secondary video memory buffer (&8000-&BFFF)
   ld__ixl 4                   ;; IXL will act as counter for the number of tiles
   ld    hl, bg_tile_offsets   ;; HL points to the start of the memory offsets for tiles
   ld    bc, g_tileset         ;; BC points to the start of the tileset
   ld    de, pbackbuffer       ;; DE points to the start of video memory, where Background should be drawn
   call  drawBackgroundTiles   ;; Draw the background

loop:
   ;; Redraw the Knight, but do it in the screen back buffer. This way, we prevent flickering
   ;; due to taking too much time drawing the knight. As it is drawn outside present video memory,
   ;; screen will not change a single bit while this drawing takes place
   ld    a, (screen_buffer)   ;; A=Most significant Byte of the video memory back buffer
   ld    d, a                 ;; | Make DE Point to video memory back buffer
   ld    e, 0                 ;; |  D = MSB, E = 0, so DE = &C000 or &8000
   call  redrawKnight         ;; Draw the knight at its concrete offset respect to video memory backbuffer

   ;; After drawing the Knight in the back buffer, we switch both buffers rapidly
   ;; And the new location of the Knight will be shown in the screen, without flickering
   call  switch_screen_buffer ;; Switch buffers after drawing the knight. 

   ;; Update Knight's location for next iteration of the look
   call  moveKnight           ;; move the knight

   jr    loop                 ;; Repeat forever

;; Include all CPCtelera definitions and variables
read "cpctelera/firmware/cpct_removeInterruptHandler.asm"
read "cpctelera/video/cpct_setVideoMode.asm"
read "cpctelera/video/cpct_setPalette.asm"
read "cpctelera/video/cpct_setPALColour.asm"
read "cpctelera/sprites/cpct_drawSprite.asm"
read "cpctelera/video/cpct_setVideoMemoryPage.asm"
read "cpctelera/sprites/cpct_drawSpriteMasked.asm"
read "cpctelera/sprites/flipping/cpct_hflipSpriteMaskedM1.asm"

;; sprites and tiles

g_spr_knight: ; defs 7250
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &00, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &00, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &30, &00, &f0, &33, &80, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &f0, &00, &f0, &33, &80, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &30, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &70, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &10, &00, &f0, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &30, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &10, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &10, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &10, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &33, &80, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &33, &80, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &11, &80, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &CC, &10, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &10, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &11, &c0, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &FF, &00, &FF, &00, &FF, &00, &CC, &00, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &00, &00, &00, &00, &00, &00, &00, &00, &FF, &00, &88, &00, &00, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &00, &00, &77, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &77, &00, &ee, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &ff, &00, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &77, &00, &ff, &00, &ff, &00, &ff, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &f0, &00, &f0, &00, &f0, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &f0, &00, &f0, &00, &f0, &00, &e0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &f0, &00, &c0, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &11, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &f0, &00, &f0, &00, &f0, &00, &b3, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &cc, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &f0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &cc, &00, &11, &00, &ff, &00, &ff, &00, &ee, &00, &77, &00, &ee, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &e0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &77, &00, &ff, &00, &88, &00, &11, &00, &ff, &00, &ff, &00, &ee, &00, &33, &00, &ff, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &c0, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &ff, &00, &88, &00, &00, &00, &ff, &00, &ff, &00, &ee, &00, &33, &00, &ff, &11, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &91, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &ff, &00, &ff, &00, &ee, &00, &11, &00, &ff, &11, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &b3, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &33, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &77, &00, &ff, &00, &ee, &00, &11, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &f0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &77, &00, &88, &00, &ff, &00, &cc, &00, &00, &00, &77, &00, &ff, &00, &ee, &00, &11, &00, &ff, &00, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &e0, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &88, &00, &77, &00, &ee, &00, &00, &00, &77, &00, &ff, &00, &ee, &00, &11, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &e0, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &00, &00, &77, &00, &ee, &00, &00, &00, &33, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &c0, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &33, &00, &ff, &00, &00, &00, &33, &00, &ff, &00, &00, &00, &33, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &ee, &77, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &f0, &00, &d1, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &77, &00, &ff, &00, &00, &00, &33, &00, &ff, &00, &00, &00, &11, &00, &ff, &00, &ff, &00, &11, &00, &ff, &00, &77, &77, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &f0, &00, &91, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &ff, &00, &ff, &00, &88, &00, &33, &00, &ff, &00, &00, &00, &11, &00, &ff, &00, &ff, &00, &00, &00, &ff, &00, &33, &77, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &f0, &00, &b3, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &ff, &00, &88, &00, &11, &00, &ff, &00, &88, &00, &11, &00, &ff, &00, &ff, &00, &00, &00, &ff, &00, &33, &33, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &b3, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &ff, &00, &cc, &00, &11, &00, &ff, &00, &88, &00, &00, &00, &ff, &00, &ff, &00, &88, &00, &ff, &00, &33, &33, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &EE, &00, &00, &70, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &ff, &00, &cc, &00, &00, &00, &ff, &00, &ff, &00, &88, &00, &ff, &00, &33, &33, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &77, &00, &99, &00, &ff, &00, &cc, &00, &00, &00, &ff, &00, &cc, &00, &00, &00, &ff, &00, &ff, &00, &88, &00, &ff, &00, &33, &11, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &70, &00, &77, &00, &ff, &00, &ff, &00, &ee, &00, &77, &00, &88, &00, &ff, &00, &ee, &00, &00, &00, &ff, &00, &cc, &00, &00, &00, &77, &00, &ff, &00, &cc, &00, &ff, &00, &33, &33, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &00, &30, &00, &77, &00, &ff, &00, &ff, &00, &ee, &00, &ff, &00, &00, &00, &77, &00, &ee, &00, &00, &00, &77, &00, &ee, &00, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &11, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &20, &00, &77, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &00, &00, &77, &00, &ee, &00, &00, &00, &77, &00, &ff, &00, &11, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &11, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &20, &00, &77, &00, &ff, &00, &ff, &00, &dd, &00, &ff, &00, &88, &00, &77, &00, &ff, &00, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &99, &11, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &77, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &88, &00, &33, &00, &ff, &00, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &88, &00, &ff, &00, &ff, &00, &99, &11, &88, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ff, &00, &cc, &00, &33, &00, &ff, &00, &88, &00, &33, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &00, &00, &ff, &00, &99, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &ff, &00, &ff, &00, &ff, &00, &33, &00, &ff, &00, &cc, &00, &33, &00, &ff, &00, &88, &00, &77, &00, &ff, &00, &ee, &00, &00, &00, &c3, &00, &0c, &00, &11, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &77, &00, &ff, &00, &cc, &00, &11, &00, &ff, &00, &cc, &00, &ff, &00, &ff, &00, &88, &00, &07, &00, &0f, &00, &0f, &00, &08, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &77, &00, &ff, &00, &ee, &00, &11, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &21, &00, &0f, &00, &0f, &00, &0f, &00, &0e, &00, &33, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &77, &00, &ff, &00, &ee, &00, &77, &00, &ff, &00, &ee, &00, &11, &00, &ff, &00, &ff, &00, &ff, &00, &88, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &19, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &77, &00, &ff, &00, &ee, &00, &77, &00, &ff, &00, &ee, &00, &00, &00, &ff, &00, &ff, &00, &ee, &00, &03, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0e, &11, &44, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &ff, &00, &ee, &00, &ff, &00, &ff, &00, &ff, &00, &00, &00, &ff, &00, &ff, &00, &88, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &ff, &00, &cc, &00, &ff, &00, &ff, &00, &ff, &00, &00, &00, &ff, &00, &ff, &00, &03, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &08, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &ff, &00, &88, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &cc, &00, &07, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &0c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &cc, &00, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &89, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0e, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &11, &00, &ff, &00, &88, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &03, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &77, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &22, &00, &77, &00, &ff, &00, &ee, &00, &77, &00, &ff, &00, &ff, &00, &cc, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &33, &08, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &22, &00, &ff, &00, &ff, &00, &ff, &00, &33, &00, &ff, &00, &ff, &00, &89, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &00, &11, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ff, &00, &ee, &00, &03, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &33, &08, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &11, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ff, &00, &cc, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &08, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &11, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &89, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &0c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &03, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &09, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &11, &0c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &ee, &00, &07, &00, &0e, &00, &0f, &00, &0f, &00, &0f, &00, &08, &00, &87, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &54, &00, &0f, &00, &0e, &00, &43, &00, &0f, &00, &0f, &00, &58, &00, &01, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &2c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &00, &00, &0f, &00, &0e, &00, &01, &00, &0f, &00, &0f, &00, &1c, &00, &c0, &00, &07, &00, &0f, &00, &0f, &00, &0f, &00, &2c, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &20, &00, &03, &00, &0e, &00, &cc, &00, &43, &00, &0f, &00, &1c, &00, &e0, &00, &01, &00, &0f, &00, &0f, &00, &0f, &00, &0e, &FF, &00, &FF, &00, &11, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &70, &00, &08, &00, &20, &00, &ff, &00, &00, &00, &43, &00, &1c, &00, &f0, &00, &c0, &00, &43, &00, &0f, &00, &0f, &00, &0e, &FF, &00, &EE, &00, &11, &44
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &70, &00, &1d, &00, &00, &00, &ff, &00, &8a, &00, &00, &00, &10, &00, &f0, &00, &95, &00, &00, &00, &0f, &00, &0f, &00, &0e, &FF, &00, &00, &11, &11, &cc
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &30, &00, &1d, &00, &ff, &00, &99, &00, &cd, &00, &f0, &00, &10, &00, &f0, &00, &95, &00, &ee, &00, &10, &00, &0f, &00, &0e, &EE, &00, &00, &ff, &00, &ee
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &30, &00, &1d, &00, &ff, &00, &11, &00, &cd, &00, &f0, &00, &f0, &00, &f0, &00, &95, &00, &cc, &00, &44, &00, &01, &00, &0e, &CC, &11, &00, &ff, &00, &ee
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &54, &00, &1d, &00, &ff, &00, &33, &00, &cd, &00, &f0, &00, &f0, &00, &f0, &00, &95, &00, &cc, &00, &cc, &00, &00, &00, &00, &CC, &11, &00, &ff, &00, &ee
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &11, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &44, &00, &15, &00, &ff, &00, &ff, &00, &dc, &00, &f0, &00, &f0, &00, &f0, &00, &95, &00, &ff, &00, &dd, &77, &00, &00, &00, &88, &33, &00, &ff, &00, &ee
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &66, &00, &11, &00, &ff, &00, &ff, &00, &b8, &00, &f0, &00, &f0, &00, &f0, &00, &95, &00, &ff, &00, &bb, &77, &00, &FF, &00, &88, &33, &00, &ff, &00, &ee
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &ff, &00, &88, &00, &ff, &00, &ff, &00, &34, &00, &f0, &00, &f0, &00, &f0, &00, &95, &00, &ee, &00, &77, &77, &00, &FF, &00, &00, &77, &00, &ff, &11, &cc
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &ff, &00, &cc, &00, &33, &00, &cc, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &c2, &00, &ee, &00, &ff, &77, &00, &EE, &00, &00, &ff, &00, &ff, &11, &cc
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &77, &00, &ff, &00, &ff, &00, &dd, &00, &ff, &00, &ee, &00, &00, &00, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &e1, &00, &11, &00, &ff, &77, &00, &EE, &00, &00, &ff, &00, &ff, &33, &88
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &ff, &00, &bb, &00, &ff, &00, &ff, &00, &cc, &00, &70, &00, &f0, &00, &d0, &00, &f0, &00, &f0, &00, &e0, &00, &77, &00, &ff, &77, &00, &CC, &11, &00, &ff, &00, &ff, &77, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &ff, &00, &ff, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &30, &00, &f0, &00, &e0, &00, &30, &00, &30, &00, &e0, &00, &ff, &00, &ff, &77, &00, &88, &11, &00, &ff, &00, &ff, &77, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &33, &00, &cc, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &b8, &00, &f0, &00, &f0, &00, &c0, &00, &f0, &00, &e0, &00, &ff, &00, &ff, &77, &00, &88, &33, &00, &ff, &00, &ee, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &00, &00, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &30, &00, &f0, &00, &f0, &00, &f0, &00, &f0, &00, &0e, &00, &ff, &00, &ff, &77, &00, &00, &77, &00, &ff, &00, &ee, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &07, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &0e, &00, &ff, &00, &ff, &77, &00, &00, &77, &00, &ff, &11, &cc, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &00, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &00, &00, &0f, &00, &0f, &00, &0f, &00, &0f, &00, &08, &00, &77, &00, &ff, &66, &00, &00, &ff, &00, &ff, &33, &88, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &77, &00, &bb, &00, &ff, &00, &ff, &00, &ee, &00, &00, &00, &00, &00, &00, &00, &03, &00, &00, &33, &00, &00, &77, &00, &ee, &EE, &00, &00, &ff, &00, &ff, &33, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &10, &00, &ff, &00, &dd, &00, &ff, &00, &ff, &00, &ee, &00, &00, &00, &33, &00, &00, &00, &00, &11, &00, &FF, &00, &00, &77, &00, &ee, &CC, &11, &00, &ff, &00, &ff, &77, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &32, &00, &f7, &00, &ee, &00, &77, &00, &ff, &00, &ee, &00, &00, &00, &33, &33, &88, &FF, &00, &FF, &00, &FF, &00, &00, &77, &11, &cc, &88, &33, &00, &ff, &00, &ee, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &00, &00, &00, &77, &00, &00, &77, &00, &f9, &00, &ff, &00, &33, &00, &ff, &00, &dc, &00, &c0, &00, &33, &11, &c8, &FF, &00, &FF, &00, &FF, &00, &00, &77, &33, &00, &88, &33, &00, &ff, &00, &ee, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ee, &77, &00, &00, &00, &00, &fc, &00, &ff, &00, &cc, &00, &ff, &00, &dc, &00, &c0, &00, &70, &00, &e0, &FF, &00, &FF, &00, &FF, &00, &00, &66, &77, &00, &00, &77, &00, &ff, &11, &cc, &FF, &00, &FF, &00
	db &FF, &00, &EE, &00, &00, &ff, &00, &ff, &00, &ff, &22, &88, &00, &00, &00, &76, &00, &ff, &00, &aa, &00, &33, &00, &dc, &00, &e2, &00, &f3, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &99, &00, &FF, &00, &00, &77, &00, &ff, &11, &88, &FF, &00, &FF, &00
	db &FF, &00, &CC, &11, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &00, &00, &76, &00, &f7, &00, &77, &00, &88, &00, &30, &00, &e0, &00, &f7, &00, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00
	db &FF, &00, &88, &33, &00, &ee, &00, &00, &00, &77, &00, &ee, &00, &00, &00, &33, &00, &f7, &00, &77, &00, &fe, &00, &b0, &00, &e0, &00, &cc, &00, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00
	db &FF, &00, &00, &77, &00, &88, &00, &00, &00, &11, &00, &ff, &00, &00, &00, &33, &00, &e2, &00, &ff, &00, &fe, &00, &f0, &00, &e0, &00, &88, &00, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &80, &00, &00, &00, &00, &00, &ff, &00, &88, &00, &11, &00, &d9, &00, &ff, &00, &fe, &00, &f0, &00, &e0, &00, &00, &00, &00, &11, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00
	db &CC, &11, &00, &ee, &00, &70, &00, &00, &00, &00, &00, &77, &00, &88, &00, &11, &00, &bb, &00, &ff, &00, &ff, &00, &fc, &00, &c0, &00, &00, &00, &30, &00, &e0, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &CC, &11, &00, &dc, &00, &f0, &00, &e0, &00, &00, &00, &77, &00, &cc, &00, &00, &00, &77, &00, &ff, &00, &ff, &00, &fc, &00, &c4, &00, &00, &00, &70, &00, &f0, &77, &00, &FF, &00, &FF, &00, &00, &77, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00
	db &CC, &11, &00, &b8, &00, &f0, &00, &f0, &00, &a0, &00, &33, &00, &cc, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &fc, &00, &c4, &00, &00, &00, &f0, &00, &00, &77, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00
	db &88, &33, &00, &70, &00, &e0, &00, &10, &00, &c0, &00, &73, &00, &ee, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &cc, &00, &10, &00, &e0, &00, &00, &11, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00
	db &88, &33, &00, &10, &00, &d1, &00, &cc, &00, &c0, &00, &11, &00, &ee, &00, &33, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &00, &44, &00, &10, &00, &c0, &00, &00, &00, &22, &66, &00, &EE, &00, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &77, &00, &70, &00, &33, &00, &ee, &00, &e0, &00, &11, &00, &ee, &00, &00, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &88, &44, &10, &00, &c0, &00, &00, &00, &ff, &00, &88, &00, &88, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &77, &00, &ff, &00, &70, &00, &11, &00, &ee, &00, &70, &00, &00, &00, &33, &00, &cc, &00, &77, &00, &cc, &CC, &10, &00, &c0, &00, &11, &00, &ff, &00, &cc, &00, &33, &00, &33, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &77, &00, &ff, &00, &70, &00, &11, &00, &ee, &00, &10, &00, &f0, &00, &80, &00, &00, &00, &77, &00, &ee, &44, &00, &00, &80, &00, &33, &00, &ff, &00, &bb, &00, &dd, &00, &dd, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &ff, &00, &ff, &00, &c8, &00, &11, &00, &ee, &00, &00, &00, &f0, &00, &f0, &00, &e0, &00, &ff, &00, &ee, &EE, &00, &00, &80, &00, &77, &00, &ff, &00, &ff, &00, &ee, &00, &66, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &ff, &00, &ff, &00, &f8, &00, &91, &00, &ee, &00, &00, &00, &10, &00, &f0, &00, &e0, &00, &ff, &00, &ee, &77, &00, &00, &40, &00, &77, &00, &ff, &00, &ff, &00, &ee, &00, &33, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &90, &00, &ff, &00, &ff, &00, &f8, &00, &b1, &00, &ee, &00, &00, &00, &00, &00, &f0, &00, &e0, &00, &77, &00, &cc, &FF, &00, &AA, &00, &00, &77, &00, &ff, &00, &ff, &00, &ee, &00, &00, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &ff, &00, &ff, &00, &70, &00, &91, &00, &ee, &00, &00, &00, &00, &00, &00, &00, &00, &00, &77, &00, &cc, &77, &00, &FF, &00, &00, &77, &00, &ff, &00, &dd, &00, &cc, &11, &44, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &77, &00, &ff, &00, &70, &00, &91, &00, &ee, &00, &00, &00, &00, &00, &00, &00, &00, &00, &33, &00, &00, &77, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &cc, &11, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &77, &00, &ee, &00, &70, &00, &11, &00, &ee, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &33, &00, &FF, &00, &88, &33, &00, &ff, &00, &ee, &00, &33, &11, &aa, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &66, &00, &f0, &00, &b3, &00, &cc, &00, &c0, &00, &33, &00, &dd, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &33, &00, &FF, &00, &CC, &00, &00, &ff, &00, &ee, &00, &ff, &11, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &00, &77, &00, &f0, &00, &c0, &00, &30, &00, &e0, &00, &b3, &00, &dd, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &11, &00, &FF, &00, &FF, &00, &00, &77, &00, &cc, &00, &77, &11, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &88, &33, &00, &10, &00, &f0, &00, &f0, &00, &e0, &00, &77, &00, &dd, &00, &00, &00, &00, &33, &00, &FF, &00, &00, &00, &00, &00, &11, &00, &FF, &00, &FF, &00, &88, &33, &00, &cc, &00, &99, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &88, &33, &00, &60, &00, &30, &00, &f0, &00, &c0, &00, &77, &00, &cc, &00, &00, &00, &00, &77, &00, &FF, &00, &00, &00, &00, &00, &00, &00, &FF, &00, &FF, &00, &CC, &11, &00, &99, &00, &ff, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &88, &33, &00, &b8, &00, &e0, &00, &70, &00, &c0, &00, &ff, &00, &bb, &00, &00, &00, &00, &FF, &00, &FF, &00, &88, &00, &00, &00, &00, &00, &FF, &00, &FF, &00, &EE, &00, &00, &33, &00, &ff, &33, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &CC, &11, &00, &dc, &00, &f0, &00, &80, &00, &80, &00, &ff, &00, &bb, &00, &00, &11, &00, &FF, &00, &FF, &00, &CC, &00, &00, &00, &00, &00, &77, &00, &FF, &00, &FF, &00, &00, &77, &00, &77, &33, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &CC, &11, &00, &ee, &00, &f0, &00, &f0, &00, &b3, &00, &ff, &00, &33, &00, &00, &33, &00, &FF, &00, &FF, &00, &EE, &00, &00, &00, &00, &00, &33, &00, &FF, &00, &CC, &00, &00, &33, &00, &cc, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &00, &00, &c0, &00, &77, &00, &ee, &00, &cc, &00, &00, &77, &00, &FF, &00, &FF, &00, &FF, &00, &00, &00, &00, &11, &11, &cc, &FF, &00, &CC, &00, &00, &33, &11, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &00, &77, &00, &cc, &00, &11, &00, &ff, &00, &dd, &00, &ee, &00, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &33, &11, &cc, &FF, &00, &88, &33, &00, &99, &11, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ff, &00, &99, &00, &ee, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &77, &00, &ee, &FF, &00, &00, &33, &11, &cc, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &CC, &00, &00, &ff, &00, &ff, &00, &ff, &00, &66, &00, &44, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &ff, &00, &ee, &FF, &00, &00, &77, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &00, &33, &00, &ff, &00, &88, &00, &00, &00, &bb, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &77, &00, &00, &33, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &00, &66, &00, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &88, &00, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &DD, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &ff, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &33, &88, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &CC, &00, &00, &00, &00, &00, &00, &11, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &cc, &00, &00, &00, &00, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &FF, &00, &00, &33, &00, &ee, &00, &77, &00, &ee, &00, &66, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &EE, &00, &00, &33, &00, &ee, &00, &77, &00, &cc, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &EE, &00, &00, &ff, &00, &ff, &00, &bb, &00, &ff, &00, &aa, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &CC, &11, &00, &ff, &00, &dd, &00, &ff, &00, &ff, &33, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &CC, &11, &00, &ff, &00, &ff, &00, &dd, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &bb, &00, &ff, &00, &ff, &11, &cc, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &88, &33, &00, &ff, &00, &ff, &00, &ee, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ff, &00, &77, &00, &ff, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &00, &77, &00, &ff, &00, &ff, &00, &ff, &00, &77, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &33, &00, &ee, &00, &ff, &00, &ff, &00, &ff, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &ee, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &dd, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &bb, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &dd, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &dd, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &dd, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &EE, &00, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &00, &dd, &00, &ee, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &00, &77, &00, &bb, &00, &ff, &00, &ff, &00, &ff, &00, &ff, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00
	db &FF, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &11, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &88, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &77, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00, &FF, &00

g_palette: db &54, &47, &43, &4b

g_tileset: 
	dw g_background_00
    dw g_background_01
    dw g_background_02
    dw g_background_03
    dw g_background_04
    dw g_background_05
    dw g_background_06
    dw g_background_07
    dw g_background_08
    dw g_background_09
    dw g_background_10
    dw g_background_11
    dw g_background_12
    dw g_background_13
    dw g_background_14
    dw g_background_15

; Tile g_background_00: 8&50 pixels, 2&50 bytes.
g_background_00: ; defs 20 * 50
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a4, &0f, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &40
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &c0
	db &f0, &f0, &f0, &f0, &f0, &c2, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &c0
	db &f0, &b4, &f0, &f0, &f0, &e0, &c3, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &c0
	db &f0, &c3, &78, &f0, &f0, &f0, &e0, &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0
	db &0f, &0f, &0f, &0f, &b4, &f0, &f0, &e1, &0f, &0c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0e, &c0
	db &0f, &0e, &0f, &0f, &0f, &0f, &0f, &09, &07, &0f, &0f, &0c, &0f, &0f, &0f, &0f, &0f, &0f, &1c, &80
	db &0e, &30, &a1, &07, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0d, &07, &0f, &0f, &2d, &0f, &0f, &38, &00
	db &70, &e0, &f0, &f0, &c1, &0f, &f0, &c3, &0f, &0f, &0e, &f0, &a1, &0f, &0e, &43, &0f, &0e, &e0, &00
	db &c0, &00, &00, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &f0, &c0, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &c0, &60, &00, &00, &00, &00, &00, &30, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &60, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &f0, &f0, &f0, &f0, &f0, &f0, &00, &00
	db &00, &00, &00, &00, &00, &e0, &e0, &f0, &d0, &70, &c0, &60, &f0, &e1, &0f, &0f, &0f, &b0, &90, &00
	db &00, &30, &d8, &f0, &f0, &f0, &f0, &e1, &f0, &0c, &20, &20, &f0, &fb, &cf, &0f, &0f, &0f, &0c, &20
	db &f3, &ff, &fc, &ff, &ff, &f0, &0f, &0f, &2d, &0f, &0f, &0f, &1f, &ff, &8f, &0f, &0f, &0f, &1c, &80
	db &73, &fe, &80, &ff, &ef, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &1f, &f0, &00, &87, &0f, &0f, &0f, &0f
	db &20, &00, &00, &cc, &00, &61, &0f, &0f, &0f, &0f, &0f, &0f, &1f, &88, &10, &f0, &f0, &c3, &0f, &0f
	db &32, &00, &00, &cc, &00, &43, &0f, &0f, &0f, &0f, &ff, &cf, &79, &88, &11, &fc, &80, &21, &0f, &0f
	db &33, &00, &00, &c0, &00, &61, &f3, &fc, &fe, &f1, &ff, &ff, &f9, &88, &11, &ff, &f0, &ff, &f8, &f0
	db &33, &00, &00, &80, &00, &70, &f7, &fe, &fe, &f3, &ec, &00, &f0, &c8, &11, &80, &31, &ff, &fe, &f0
	db &72, &00, &80, &00, &00, &70, &fe, &00, &c4, &73, &88, &00, &11, &c8, &31, &80, &73, &c0, &10, &f1
	db &72, &00, &80, &10, &00, &71, &ec, &00, &44, &73, &00, &70, &21, &c8, &33, &00, &f6, &00, &00, &73
	db &72, &00, &40, &11, &00, &71, &cc, &00, &00, &71, &00, &77, &f8, &c8, &22, &10, &ee, &31, &00, &33
	db &76, &00, &44, &31, &00, &31, &c8, &30, &00, &70, &00, &30, &f6, &c8, &00, &30, &ec, &73, &00, &33
	db &66, &00, &64, &32, &00, &31, &88, &30, &80, &70, &80, &00, &00, &c8, &00, &10, &cc, &72, &00, &33
	db &66, &00, &06, &76, &00, &31, &88, &33, &c8, &72, &e0, &00, &00, &40, &00, &00, &cc, &00, &00, &71
	db &66, &00, &16, &e6, &00, &30, &88, &11, &c8, &73, &f8, &c8, &00, &40, &20, &00, &44, &00, &10, &f9
	db &66, &00, &07, &ee, &00, &30, &88, &00, &00, &73, &73, &cc, &00, &40, &30, &00, &00, &00, &f6, &90
	db &ee, &00, &17, &ec, &00, &30, &c0, &00, &00, &34, &11, &c8, &00, &c0, &10, &c0, &00, &00, &00, &10
	db &00, &00, &43, &48, &00, &10, &c0, &00, &00, &70, &00, &00, &00, &80, &10, &e8, &00, &00, &00, &50
	db &00, &00, &03, &08, &00, &00, &e0, &00, &c0, &60, &e0, &00, &30, &80, &10, &e0, &30, &80, &10, &f0
	db &10, &e0, &90, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &f0, &f0, &f0, &f0
	db &10, &e1, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &1e, &70, &f0, &f0, &f1, &ff, &f3, &fe, &f0, &f0, &f0, &f7, &f0, &f0, &f0, &f0, &f0, &f4
	db &10, &c3, &1e, &f0, &f0, &f0, &f1, &ff, &f7, &fc, &f0, &f0, &f0, &b7, &f0, &f0, &f0, &f0, &f3, &fc
	db &10, &c2, &0e, &f0, &f0, &f0, &f1, &ff, &ff, &fc, &f0, &f0, &f0, &f3, &f0, &f0, &f0, &f0, &ff, &f8
	db &10, &c3, &1e, &f0, &f0, &f0, &f1, &fd, &ff, &fe, &f3, &fc, &f3, &fb, &f1, &ff, &f0, &f0, &f3, &f8
	db &20, &c3, &1e, &f0, &f0, &f0, &f1, &fd, &fd, &fe, &f6, &fe, &f6, &f7, &f3, &f7, &f8, &f0, &f3, &f8
	db &30, &c3, &1e, &f0, &f0, &f0, &f1, &fc, &f9, &fe, &fc, &ff, &fe, &f3, &f6, &f7, &f8, &f0, &f3, &f8
	db &30, &c2, &1e, &f0, &f0, &f0, &f3, &fc, &f3, &fe, &ff, &ff, &ff, &ff, &f7, &ff, &f0, &f0, &f3, &f8
	db &20, &c2, &1e, &f0, &f0, &f0, &f3, &fc, &f3, &fe, &ff, &ff, &ff, &ff, &f7, &f8, &f8, &f0, &f3, &f8
	db &00, &c2, &1e, &f0, &f0, &f0, &f3, &fe, &f7, &ff, &ff, &fe, &f7, &ff, &f3, &ff, &f8, &f0, &f3, &f0
	db &10, &61, &1e, &f0, &f0, &f0, &f0, &f2, &f0, &f0, &f3, &fc, &f1, &ff, &f1, &ff, &f0, &f0, &f7, &f8
	db &10, &e1, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &41, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &41, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_01: 8&50 pixels, 2&50 bytes.
g_background_01: ; defs 20 * 50
	db &10, &c0, &16, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &c3, &16, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &c3, &16, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &82, &16, &f0, &f0, &f0, &f0, &f0, &f0, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &82, &14, &f0, &f0, &f0, &f0, &e0, &07, &0f, &0f, &2c, &00, &70, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &1e, &87, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c2, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &3c
	db &10, &e0, &0e, &0f, &0f, &0f, &0f, &0f, &0f, &3c, &87, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &00, &f0, &f0, &f0, &e0, &00, &70, &f0, &f0, &c0, &00, &1c, &96, &f0, &3c, &87, &0f, &0f, &0f, &0f
	db &00, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &0f, &0f, &0f
	db &00, &10, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &3c
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &30, &10, &80, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &90, &c0, &f0, &f0, &80, &05, &16, &2d, &1c, &f0, &f0
	db &10, &72, &c8, &40, &20, &30, &f7, &fe, &f0, &e0, &30, &f0, &e1, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &f0, &f3, &fc, &b0, &f0, &f1, &ff, &ff, &f8, &e0, &90, &f0, &e1, &0f, &0f, &0f, &0f, &1f, &ff, &8f
	db &0f, &2e, &10, &87, &0f, &3f, &ec, &00, &d7, &1c, &f0, &f0, &f0, &87, &0f, &0f, &0f, &3f, &ff, &cf
	db &0f, &3f, &00, &0f, &0f, &3f, &88, &00, &11, &4b, &0f, &38, &f0, &d2, &d2, &f0, &f0, &f1, &08, &01
	db &0f, &1f, &00, &0f, &0f, &3f, &80, &00, &00, &83, &0f, &0c, &f0, &c3, &3c, &f0, &f0, &f0, &00, &00
	db &f7, &f9, &80, &f0, &f0, &73, &00, &00, &00, &21, &7f, &bf, &fe, &f1, &fe, &f7, &f8, &f3, &80, &10
	db &ff, &ff, &80, &f0, &f0, &f1, &00, &00, &70, &21, &7f, &7f, &ff, &f0, &ff, &ff, &fe, &f1, &ff, &f1
	db &ec, &10, &88, &f0, &f0, &f0, &00, &00, &74, &81, &7c, &11, &80, &f0, &88, &64, &30, &f0, &00, &10
	db &c8, &00, &00, &f0, &f0, &f0, &80, &00, &33, &f8, &e6, &20, &00, &03, &c8, &40, &00, &70, &c8, &31
	db &88, &60, &00, &f0, &f0, &f0, &c0, &00, &00, &f6, &e6, &00, &00, &31, &c8, &00, &00, &f1, &c8, &31
	db &00, &70, &00, &f0, &f0, &f0, &f0, &00, &00, &10, &e6, &00, &80, &11, &c8, &00, &00, &f1, &c8, &30
	db &00, &73, &80, &f0, &f0, &f1, &f8, &e6, &00, &00, &62, &11, &88, &11, &c8, &00, &00, &f1, &c8, &30
	db &00, &31, &80, &f0, &f0, &f1, &f3, &ff, &00, &00, &22, &31, &88, &11, &88, &30, &c0, &f1, &c8, &30
	db &00, &00, &00, &f0, &f0, &f0, &18, &fe, &00, &00, &22, &31, &00, &11, &88, &70, &f0, &f1, &88, &30
	db &80, &00, &00, &f0, &f0, &f0, &80, &00, &00, &00, &22, &00, &00, &31, &88, &34, &f0, &f1, &88, &10
	db &80, &00, &00, &f0, &f0, &f0, &c0, &00, &00, &00, &66, &00, &00, &31, &88, &70, &f0, &f3, &88, &10
	db &c0, &00, &00, &f0, &f0, &f0, &f0, &00, &00, &00, &e6, &00, &00, &70, &80, &70, &f0, &f0, &80, &10
	db &f0, &80, &00, &70, &f0, &f0, &f0, &e0, &00, &30, &e6, &60, &00, &f0, &80, &30, &f0, &f0, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e6, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e6, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &ee, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &10, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &e0, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &e1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_02: 8&50 pixels, 2&50 bytes.
g_background_02: ; defs 20 * 50
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1c, &c0, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1e, &c0, &00, &00, &00, &10, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1e, &c0, &00, &e0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1e, &c0, &10, &f0, &00, &0f, &1e
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1c, &c0, &30, &83, &0f, &0f, &68
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1e, &c0, &30, &03, &38, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &3c, &80, &30, &07, &f0, &f0, &f0
	db &78, &c3, &96, &a5, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &3c, &40, &30, &16, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &68, &c0, &20, &16, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &30, &f0, &f0, &40, &10, &96, &f0, &f0, &f0
	db &0f, &0f, &78, &c0, &00, &f0, &e0, &06, &00, &10, &20, &f0, &f0, &e0, &00, &10, &1c, &f0, &f0, &f0
	db &00, &00, &30, &10, &80, &c0, &60, &30, &00, &00, &c0, &00, &00, &00, &00, &10, &1c, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &80, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &1c, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &61, &1c, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &10, &f0, &78, &87, &0f, &0b, &1e, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &10, &83, &0f, &0f, &0f, &0f, &1e, &f0, &f0, &f0
	db &3f, &ff, &d8, &f0, &f0, &f0, &f0, &f0, &e0, &00, &10, &3f, &ff, &0f, &1f, &8f, &3c, &f0, &f0, &f0
	db &1f, &ff, &0f, &0c, &f0, &f0, &f0, &f0, &e0, &f1, &ff, &ff, &ff, &0f, &ff, &8f, &ff, &fc, &f0, &f0
	db &1e, &00, &10, &0f, &0f, &0f, &0f, &0f, &3c, &f7, &ff, &fc, &c0, &33, &ff, &91, &ff, &fe, &f0, &f0
	db &1f, &88, &03, &0f, &0f, &0f, &0f, &0f, &3c, &10, &00, &00, &00, &31, &c8, &10, &c8, &00, &f0, &f0
	db &7b, &88, &27, &0f, &0f, &0f, &0f, &0f, &3c, &80, &00, &00, &00, &31, &00, &10, &80, &00, &70, &f0
	db &f3, &80, &67, &97, &ff, &f8, &f0, &87, &3c, &91, &80, &00, &00, &31, &88, &11, &c8, &00, &f7, &f9
	db &fb, &80, &76, &37, &ff, &fe, &f0, &0f, &3c, &31, &88, &30, &f8, &b1, &88, &30, &ff, &f8, &f7, &f7
	db &bb, &00, &00, &77, &c0, &10, &f0, &c3, &1c, &b1, &88, &31, &d8, &d1, &88, &30, &80, &00, &f0, &11
	db &88, &00, &00, &76, &00, &00, &70, &0f, &1e, &b1, &80, &11, &90, &f1, &88, &30, &e4, &10, &e6, &20
	db &80, &00, &00, &66, &31, &00, &30, &87, &1e, &b3, &80, &00, &10, &f1, &88, &30, &ec, &10, &e6, &00
	db &80, &00, &f0, &64, &73, &00, &30, &0f, &3c, &b3, &00, &00, &00, &f1, &88, &30, &ec, &10, &e6, &00
	db &e2, &00, &f2, &cc, &72, &00, &30, &87, &3c, &b3, &00, &00, &00, &f1, &88, &30, &ec, &10, &e6, &11
	db &e6, &00, &ff, &cc, &00, &00, &70, &c3, &3c, &f3, &00, &01, &2c, &f1, &88, &30, &ec, &10, &e6, &31
	db &e6, &00, &f6, &40, &00, &10, &f8, &c3, &1e, &f3, &00, &01, &0e, &f1, &88, &70, &cc, &10, &e6, &31
	db &e2, &00, &00, &40, &00, &f6, &90, &87, &1e, &f7, &00, &01, &0f, &f1, &88, &70, &cc, &00, &e6, &00
	db &e0, &00, &00, &20, &00, &00, &10, &c3, &1e, &fe, &00, &10, &1e, &f3, &88, &71, &cc, &00, &e6, &00
	db &f0, &00, &00, &b0, &00, &00, &50, &87, &3c, &c0, &00, &00, &3c, &f0, &80, &70, &c0, &00, &e6, &00
	db &f0, &80, &30, &f0, &80, &10, &f0, &87, &3c, &c0, &00, &00, &1e, &f0, &00, &30, &80, &00, &66, &60
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &80, &10, &80, &70, &f0, &f0, &f0, &f0, &f0, &e6, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &10, &c3, &1e, &f0, &f0, &f0, &f0, &f0, &e6, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &10, &87, &3c, &f0, &f0, &f0, &f0, &f0, &ee, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &30, &83, &78, &f0, &f0, &f0, &f0, &f0, &e0, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &30, &87, &3c, &f0, &f0, &f0, &f0, &f0, &c0, &10
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &30, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &10, &07, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &10, &0f, &78, &f0, &f0, &e0, &f0, &f0, &b0, &b0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &10, &0f, &78, &f0, &f0, &80, &70, &c0, &43, &78
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &10, &0f, &69, &4b, &87, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &c0, &10, &07, &0f, &2d, &0f, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &10, &87, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &00, &e1, &0f, &0f, &1e, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &80, &00, &61, &0f, &0f, &3c, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &80, &00, &20, &f0, &f0, &f0, &f0, &f0, &b0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &80, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00

; Tile g_background_03: 8&50 pixels, 2&50 bytes.
g_background_03: ; defs 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &10, &a1, &78, &f0, &f0
	db &00, &00, &00, &00, &00, &40, &00, &00, &00, &40, &70, &80, &70, &80, &00, &30, &c1, &78, &f0, &f0
	db &c0, &f0, &f0, &f0, &f0, &f0, &00, &20, &60, &70, &f0, &f0, &f0, &80, &00, &10, &01, &78, &f0, &f0
	db &0f, &02, &00, &20, &40, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &40, &10, &c3, &78, &f0, &f0
	db &c1, &83, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &08, &00, &f0, &f0, &80, &10, &81, &78, &f0, &f0
	db &f0, &f0, &f0, &70, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &3c, &80, &10, &e1, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &b0, &c3, &0f, &0f, &1e, &80, &30, &c0, &3c, &f0, &02
	db &f0, &f0, &f0, &f0, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0f, &0e, &e0, &10, &c0, &1e, &f0, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &0f, &c0, &d0, &c3, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &0f, &c0, &10, &c1, &0f, &0f, &0c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &28, &10, &f0, &00, &09, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0c, &00, &60, &30, &10, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0c, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &2c, &10, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &2c, &70, &e0, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &0f, &2c, &e0, &00, &00
	db &f0, &f0, &f0, &f0, &ff, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &09, &87, &0f, &68, &00, &00
	db &f0, &f0, &f0, &f0, &f7, &ff, &ff, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &70, &e1, &0f, &38, &00, &00
	db &f0, &f0, &f0, &f0, &c0, &70, &ff, &fc, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0, &00
	db &f0, &f0, &f0, &f0, &f2, &00, &00, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &00
	db &f0, &f0, &f0, &f0, &f3, &00, &00, &00, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &0f, &78, &00
	db &fe, &f0, &f0, &f0, &f1, &00, &20, &00, &70, &f7, &fc, &f0, &ff, &f3, &f0, &fe, &f0, &f7, &de, &80
	db &ff, &f0, &f0, &f0, &f1, &80, &32, &00, &31, &ff, &ff, &f0, &f7, &ff, &f9, &ff, &f1, &ff, &ef, &c0
	db &80, &f0, &f0, &f0, &f1, &80, &33, &00, &11, &e8, &00, &f0, &e4, &32, &31, &c8, &73, &e8, &10, &48
	db &00, &30, &f0, &f0, &f1, &80, &73, &00, &11, &80, &00, &30, &e4, &00, &10, &80, &33, &80, &00, &60
	db &00, &30, &f0, &f0, &f1, &88, &72, &00, &11, &10, &88, &10, &e6, &00, &00, &00, &30, &10, &88, &20
	db &80, &10, &f0, &f0, &f1, &88, &66, &00, &10, &31, &88, &10, &e6, &00, &00, &00, &10, &33, &88, &00
	db &88, &10, &f0, &f0, &f1, &88, &40, &00, &00, &31, &80, &10, &e6, &00, &00, &00, &00, &73, &00, &00
	db &88, &10, &f0, &f0, &f0, &88, &00, &00, &20, &00, &00, &30, &e6, &00, &00, &00, &00, &00, &00, &00
	db &00, &10, &f0, &f0, &f0, &c8, &00, &00, &22, &00, &00, &f4, &e6, &00, &00, &64, &00, &00, &00, &00
	db &00, &30, &f0, &f0, &f0, &c8, &00, &00, &60, &00, &73, &c0, &e6, &11, &80, &e6, &20, &00, &00, &00
	db &00, &30, &f0, &f0, &f7, &c8, &00, &00, &f0, &00, &00, &00, &ee, &30, &80, &ee, &30, &00, &00, &20
	db &00, &70, &f0, &f0, &f0, &c0, &00, &30, &f0, &80, &00, &20, &e0, &30, &80, &c0, &70, &80, &00, &24
	db &00, &f0, &f0, &f0, &e0, &00, &70, &f0, &f0, &c0, &00, &f0, &c0, &10, &f0, &c0, &30, &c0, &10, &2c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &2c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &2c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &0c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &0c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &68
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0b, &08
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &08
	db &b4, &d2, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0b, &20
	db &f0, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d2, &f0, &f0, &f0, &f0, &f0, &e1, &0b, &40
	db &0f, &0f, &f0, &f0, &f0, &f0, &f0, &96, &0f, &0f, &0f, &0f, &e0, &70, &f0, &d2, &90, &c3, &0f, &40
	db &0f, &0f, &0f, &0f, &78, &a5, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &68
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &48
	db &f0, &01, &0f, &0f, &0f, &0f, &0f, &07, &0f, &0f, &0f, &12, &0e, &f0, &d0, &f0, &f0, &f0, &83, &c0
	db &f0, &e0, &0f, &0f, &0f, &60, &c0, &c0, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &90, &c0
	db &f0, &f0, &f0, &d0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &70, &10, &c0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &10, &00

; Tile g_background_04: 8&50 pixels, 2&50 bytes.
g_background_04: ; defs 20 * 50
	db &00, &41, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c1, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &e0, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &e1, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c1, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c1, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &43, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &03, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &81, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &81, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &81, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &43, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &83, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &e0, &f0, &50, &80, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &e0, &20, &80, &d0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &20, &00, &90, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &10, &70, &b0, &00, &e0, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &10, &d0, &80, &a0, &20, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &30, &c2, &f0, &e0, &00, &14, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &10, &d2, &f0, &c0, &00, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &10, &d2, &f0, &e0, &40, &d2, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &30, &c2, &f0, &f0, &60, &20, &40, &20, &10, &40, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &30, &92, &f0, &f0, &40, &01, &10, &80, &c0, &60, &20, &f0, &f0, &f0, &f0, &f0, &d0, &a0
	db &00, &00, &10, &12, &80, &c0, &e0, &00, &81, &90, &c0, &60, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &00, &00, &10, &00, &00, &50, &80, &00, &01, &08, &01, &0f, &0f, &0d, &07, &0f, &0f, &05, &0f, &0f
	db &00, &00, &30, &10, &80, &f0, &e0, &00, &00, &00, &c0, &f0, &f0, &f0, &90, &40, &60, &30, &10, &90
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &60, &00, &00, &00

; Tile g_background_05: 8&50 pixels, 2&50 bytes.
g_background_05: ; defs 20 * 50
	db &f0, &f0, &f0, &e1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &e0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &16, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &07, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &0c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0f, &3c, &f0, &f0, &f0, &f0, &f0
	db &d0, &f0, &f0, &f0, &f0, &f0, &d0, &f0, &f0, &f0, &f0, &f0, &07, &0f, &0f, &08, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &0f, &0b, &0c, &07, &0f, &0f, &0f, &07, &0f, &0f, &0f, &0f, &07, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &50, &e0, &b0, &50, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &1c, &80, &07, &0c, &08, &00, &41, &f0, &20
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00

; Tile g_background_06: 8&50 pixels, 2&50 bytes.
g_background_06: ; defs 20 * 50
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &c0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1c, &c0, &00, &00, &30, &e0, &f0, &c0, &60, &00, &00, &00
	db &f0, &3c, &f0, &f0, &f0, &f0, &f0, &87, &1c, &c0, &00, &00, &b0, &f0, &f0, &f0, &e0, &80, &00, &00
	db &f0, &0f, &78, &f0, &f0, &f0, &f0, &87, &1c, &c0, &00, &30, &f0, &f0, &0b, &0f, &0f, &70, &f0, &f0
	db &f0, &c3, &1a, &f0, &f0, &f0, &f0, &87, &1e, &c0, &10, &f0, &e1, &0f, &0f, &0f, &0f, &0f, &38, &e0
	db &f0, &c1, &0f, &70, &f0, &f0, &f0, &87, &1c, &c0, &10, &f0, &07, &0f, &0f, &0f, &0f, &0f, &3c, &e1
	db &f0, &f0, &0f, &3c, &f0, &f0, &f0, &87, &1c, &80, &10, &c3, &0f, &0f, &0f, &0f, &09, &0e, &0b, &0f
	db &f0, &f0, &87, &1c, &f0, &f0, &d2, &87, &1c, &80, &10, &83, &0f, &0f, &1e, &f0, &f0, &f0, &87, &0f
	db &f0, &f0, &c3, &0f, &70, &f0, &c0, &0f, &1c, &80, &10, &0f, &0f, &78, &f0, &f0, &f0, &e0, &0f, &0f
	db &f0, &f0, &e0, &0f, &1e, &f0, &f0, &87, &0e, &80, &00, &0f, &1a, &f0, &f0, &f0, &f0, &e1, &07, &78
	db &f0, &f0, &f0, &07, &0e, &f0, &f0, &c1, &1e, &a0, &10, &0f, &78, &f0, &f0, &f0, &f0, &c3, &1e, &f0
	db &f0, &f0, &f0, &c3, &0f, &78, &f0, &f0, &f0, &80, &00, &07, &78, &f0, &f0, &f0, &f0, &83, &38, &f0
	db &f0, &f0, &f0, &c3, &0f, &18, &e0, &f0, &f0, &80, &10, &07, &78, &f0, &f0, &f0, &f0, &f0, &70, &f0
	db &f0, &f0, &f0, &e0, &0f, &0e, &70, &c0, &00, &00, &10, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &07, &0f, &38, &40, &00, &00, &10, &07, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &c3, &0f, &70, &80, &00, &00, &10, &07, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &e1, &0f, &3c, &c0, &00, &00, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &e1, &0f, &3c, &e0, &00, &00, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &87, &0e, &f0, &40, &00, &00, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &c3, &0f, &f0, &80, &00, &00, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &c1, &0f, &f0, &e0, &00, &10, &83, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &70, &80, &00, &00, &83, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &80, &00, &00, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &80, &00, &10, &c1, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &83, &18, &e0, &00, &00, &c1, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &83, &1c, &e0, &00, &00, &e1, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1e, &c0, &00, &00, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1c, &c0, &00, &00, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1e, &c0, &00, &00, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &c0, &00, &10, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &40, &00, &00, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &f0, &00, &00, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e0, &0e, &d0, &00, &10, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0e, &c0, &00, &10, &43, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &c0, &00, &10, &83, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &1e, &c0, &00, &10, &83, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &1c, &e0, &00, &30, &07, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &e0, &00, &30, &c3, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &d0, &00, &10, &c3, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0b, &00, &00, &30, &43, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &00, &00, &30, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &40, &00, &30, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &1e, &60, &00, &30, &c3, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &00, &00, &30, &83, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c0, &0f, &c0, &00, &30, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1e, &40, &00, &30, &c1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &78, &30, &80, &00, &30, &e0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &70, &f0, &00, &00, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0e, &00, &00, &d0, &f0, &f0, &00, &00, &00, &f0, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &10, &00, &00, &00, &00, &00, &00, &00, &c0, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_07: 8&50 pixels, 2&50 bytes.
g_background_07: ; 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &90, &80, &10, &00
	db &00, &20, &30, &f0, &f0, &a4, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &00, &00
	db &f0, &83, &0c, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &1e, &a5, &f0, &f0, &f0, &f0, &f0, &60, &00, &00
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &09, &0f, &0f, &0f, &38, &e0, &00
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0e, &70, &80
	db &0f, &0f, &0f, &0f, &0f, &3c, &f0, &f0, &4b, &0f, &0f, &0f, &0f, &0f, &1e, &30, &c3, &0f, &3c, &80
	db &0f, &1a, &c2, &c0, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &90, &f0, &f0, &f0, &f0, &87, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1e, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0e, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &0e, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &04, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &14, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &87, &0f, &0e, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &0e, &f0, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1e, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0f, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &1e, &c1, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1e, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &69, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &06, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &06, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &06, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &14, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &70, &f0, &f0, &f0, &f0, &f0, &c2, &04, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &00, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &70, &f0, &f0, &f0, &f0, &f0, &82, &20, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &f0, &f0, &f0, &f0, &f0, &f0, &82, &30, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &82, &20, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &87, &38, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &f0, &f0, &f0, &f0, &f0, &f0, &87, &38, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &70, &f0, &f0, &f0, &f0, &f0, &87, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &78, &f0, &f0, &f0, &f0, &f0, &87, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &78, &f0, &f0, &f0, &f0, &f0, &87, &f0, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &78, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &70, &f0, &f0, &f0, &f0, &f0, &87, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &78, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &f0, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &70, &e0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &f0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &f0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &96, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a4, &f0, &80

; Tile g_background_08: 8&50 pixels, 2&50 bytes.
g_background_08: ; defs 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &10, &10, &d0, &80, &00, &10, &e0, &80, &70, &e0, &b0, &b0, &40, &00, &00, &00, &00
	db &00, &00, &70, &f0, &e0, &c0, &20, &30, &10, &a0, &50, &e0, &f0, &f0, &f0, &f0, &90, &70, &80, &00
	db &00, &30, &f0, &b0, &80, &c0, &60, &30, &10, &3c, &f0, &e0, &70, &50, &90, &c0, &f0, &f0, &c0, &00
	db &10, &70, &00, &00, &0f, &0f, &0f, &0f, &0f, &38, &10, &83, &00, &01, &04, &00, &18, &50, &c0, &00
	db &10, &e0, &00, &07, &0f, &1e, &20, &b0, &f0, &d0, &10, &07, &03, &0f, &0f, &0d, &1c, &80, &e0, &00
	db &10, &e0, &21, &3c, &f0, &f0, &f0, &f0, &f0, &e0, &c1, &0f, &0f, &0f, &38, &d0, &c3, &16, &30, &00
	db &10, &90, &16, &f0, &f0, &f0, &f0, &f0, &f0, &00, &06, &f0, &f0, &f0, &f0, &f0, &f0, &08, &10, &00
	db &10, &80, &38, &f0, &f0, &f0, &f0, &f0, &f0, &21, &58, &f0, &f0, &f0, &f0, &f0, &f0, &80, &70, &00
	db &30, &21, &70, &f0, &f0, &f0, &f0, &f0, &f0, &90, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &92, &70, &80
	db &10, &c3, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &70, &b0, &80
	db &70, &c2, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &90, &f0, &00
	db &f0, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &80
	db &16, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &92, &92, &b0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0c, &d2, &d0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1e, &70, &e1, &78, &00
	db &a0, &0f, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0f, &1e, &f0, &d0, &00, &60, &00
	db &0f, &0f, &78, &f0, &e0, &f0, &e0, &f0, &f0, &81, &1e, &83, &0f, &14, &f0, &d0, &f0, &f0, &f0, &00
	db &0f, &0f, &70, &f0, &80, &41, &07, &10, &10, &80, &00, &f0, &f0, &f0, &f0, &f0, &60, &f0, &c0, &00
	db &09, &60, &f0, &f0, &e0, &00, &00, &00, &00, &00, &00, &f0, &f0, &f0, &f0, &f0, &00, &70, &80, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &e0, &70, &d0, &f0, &f0, &f0, &f0, &f0, &d0, &e0, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &e0, &30, &10, &b0, &c0, &60, &30, &10, &80, &c0, &60, &30, &70, &40, &00, &00, &00, &00, &00
	db &e0, &c3, &08, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &00, &e0, &80, &00, &00
	db &0f, &0f, &0f, &0f, &1c, &b0, &80, &70, &f0, &10, &c0, &b0, &f0, &d0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0e, &04, &07, &08, &07, &0f, &0f, &00, &0c, &00, &70, &f0
	db &0f, &0f, &0f, &c2, &3c, &e0, &d0, &f0, &80, &83, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0c, &10
	db &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &70, &20, &81, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &10
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &b0, &f0, &f0, &f0, &81, &70, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &3c, &f0, &a0, &1e, &70, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &41, &0f, &0f, &08, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &e0, &07, &0f, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &a0, &05, &0f, &08, &01, &0f, &0f, &0f, &0f, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &87, &07, &0f, &0f, &0f, &0f, &0f, &28, &83, &58, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0e, &60, &f0, &f0, &b0, &c0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &70, &70, &70, &f0, &c0, &80, &00, &90, &f0, &52, &d0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0e, &f0, &f0, &f0, &b0, &40, &00, &00, &20, &70, &03, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &d0, &f0, &e0, &00, &00, &00, &00, &10, &a1, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_09: 8&50 pixels, 2&50 bytes.
g_background_09: ; defs 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &10, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &00, &f0
	db &00, &00, &40, &70, &f0, &f0, &d2, &f0, &00, &0c, &60, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &10, &70, &e1, &30, &f0, &f0, &49, &0b, &0f, &0f, &0f, &0f, &0e, &0b, &03, &0c, &70, &f0, &d0
	db &00, &10, &70, &d0, &48, &d0, &d0, &0d, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &00, &10, &f0, &83, &07, &78, &d0, &70, &f0, &f0, &f0, &f0, &80, &03, &0f, &0f, &0f, &0f, &0f, &0f
	db &00, &30, &f0, &b4, &f0, &86, &d0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &92, &a0, &0f, &0f, &0f
	db &00, &30, &e1, &78, &f0, &f0, &3c, &94, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &78, &f0, &f0, &f0, &82
	db &00, &f0, &96, &f0, &f0, &f0, &d2, &86, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &90, &f0, &f0, &f0, &f0
	db &00, &60, &96, &f0, &f0, &f0, &e1, &c3, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &3c, &f0, &f0, &f0, &f0, &85, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &38, &f0, &f0, &f0, &f0, &c3, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &38, &f0, &f0, &f0, &f0, &e1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &d0, &78, &f0, &f0, &f0, &f0, &f0, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c0, &78, &f0, &f0, &f0, &f0, &f0, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &d2, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &d0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &c0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &90, &3c, &f0, &f0, &f0, &f0, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &2c, &60, &c2, &20, &43, &83, &58, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &e1, &0e, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &38, &c0, &00, &03, &0f, &0f, &0f, &0f, &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &40, &f0, &f0, &f0, &f0, &e0, &b0, &40, &50, &83, &0f, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &20, &00, &00, &00, &30, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &30, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &30, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &40, &00, &00, &70, &0b, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &00, &30, &0f, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &70, &0f, &0f, &38, &f0, &f0, &f0, &f0, &f0, &f0
	db &a0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &30, &0f, &0f, &0f, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0c, &00, &0f, &0f, &1c, &96, &f0, &00, &10, &d0, &e0, &0f, &0f, &78, &f0, &f0, &f0, &1e
	db &87, &0f, &0f, &0f, &0f, &0f, &0f, &1c, &e0, &00, &00, &80, &f0, &c1, &0f, &0f, &0c, &87, &0f, &0f
	db &f0, &c0, &07, &3c, &0c, &00, &0f, &0e, &60, &00, &00, &00, &00, &d0, &83, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0f, &70, &00, &00, &00, &00, &00, &f0, &b4, &0b, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &60, &00, &00, &00, &00, &00, &30, &f0, &10, &87, &0f, &78
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &68, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &68, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &68, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &70, &80, &00, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &00, &00, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &80, &10, &f0, &f0, &e1, &96, &87, &87, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &80, &10, &f0, &f0, &c3, &0b, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &00, &30, &f0, &87, &0f, &0f, &0f, &0f, &0f, &1e, &b4
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &78, &00, &30, &e1, &07, &0f, &0f, &0f, &1e, &f0, &e1, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &78, &00, &30, &e1, &0f, &0f, &0f, &f0, &e1, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &f0, &80, &30, &c1, &0f, &80, &00, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &f0, &c0, &30, &c3, &1e, &70, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c1, &0e, &e0, &c0, &30, &c1, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &70, &80, &30, &c3, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_10: 8&50 pixels, 2&50 bytes.
g_background_10: ; defs 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &c1, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &61, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &30, &90, &00, &00, &60, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &e0, &00, &70, &e0, &00, &00, &00, &f0, &f0, &c0, &00, &60, &10, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &e0, &20, &00, &00, &70, &21, &70, &80, &00, &30, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0c, &30, &f0, &f0, &c0, &10, &c1, &d2, &b4, &80, &00, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &08, &30, &c0, &30, &12, &f0, &f0, &c0, &00, &70, &90, &f0, &f0, &e0, &30, &e0, &70, &00
	db &0f, &0f, &0f, &0e, &c0, &30, &50, &f0, &80, &c0, &00, &70, &96, &f0, &e0, &10, &00, &03, &1c, &0f
	db &07, &0f, &0f, &0f, &c0, &10, &f0, &f0, &c2, &c0, &00, &f0, &07, &0f, &0f, &0f, &0f, &86, &10, &30
	db &03, &38, &07, &0f, &40, &10, &92, &f0, &d2, &c0, &00, &70, &87, &08, &00, &00, &10, &f0, &f0, &f0
	db &f0, &f0, &c3, &0f, &48, &10, &96, &f0, &d2, &c0, &00, &70, &f0, &f0, &a0, &10, &10, &00, &00, &00
	db &f0, &f0, &c1, &0f, &08, &10, &96, &f0, &c2, &c0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &e1, &0f, &08, &30, &12, &f0, &c2, &c0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &0f, &2c, &10, &96, &f0, &c3, &2c, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &0f, &0c, &10, &96, &f0, &c3, &28, &80, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &07, &0c, &10, &92, &f0, &c3, &3c, &c0, &60, &00, &20, &00, &10, &f0, &60, &20, &f0
	db &f0, &f0, &f0, &0f, &2c, &10, &82, &f0, &c3, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &87, &0c, &10, &82, &f0, &c3, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &0c, &70, &82, &f0, &f0, &0e, &0f, &0c, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &87, &2c, &30, &87, &f0, &f0, &f0, &f0, &f0, &07, &0f, &0e, &0f, &4b, &08, &0e, &f0
	db &f0, &f0, &f0, &87, &08, &70, &83, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &87, &0c, &70, &07, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &0c, &30, &03, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &0c, &70, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &0c, &10, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &0c, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &0f, &48, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &e1, &0f, &08, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &e1, &0f, &48, &10, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &e1, &0f, &c0, &30, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &4b, &0f, &48, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &87, &0f, &0f, &c0, &10, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &1c, &80, &30, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &58, &00, &30, &87, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &1e, &0e, &c0, &00, &10, &83, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &b4, &f0, &1c, &e0, &00, &10, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &c0, &40, &30, &00, &00, &10, &87, &5a, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &10, &87, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &10, &87, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &c0, &10, &83, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &83, &10, &e1, &78, &c0, &10, &0f, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &1c, &c0, &10, &c3, &0e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &1e, &5a, &0f, &3c, &c0, &10, &c3, &0f, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &0f, &3c, &c0, &10, &e1, &0f, &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &c3, &0f, &c0, &10, &f0, &87, &0f, &0f, &0f, &0f, &0c, &70, &f0, &f0, &f0, &f0, &70, &07
	db &f0, &f0, &87, &0f, &c0, &00, &f0, &c3, &0f, &0f, &0f, &0f, &0f, &0f, &18, &80, &83, &0f, &0f, &0f
	db &f0, &f0, &87, &0e, &c0, &00, &70, &f0, &f0, &c0, &e0, &10, &0e, &03, &01, &0f, &f0, &60, &f0, &00
	db &f0, &f0, &87, &0e, &c0, &00, &30, &f0, &f0, &f0, &f0, &f0, &e0, &50, &c0, &00, &10, &f0, &f0, &00
	db &f0, &f0, &e1, &0f, &c0, &00, &00, &50, &f0, &f0, &70, &f0, &70, &f0, &b0, &f0, &c0, &30, &10, &80
	db &f0, &f0, &e1, &0e, &c0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00

; Tile g_background_11: 8&50 pixels, 2&50 bytes.
g_background_11: ; defs 20 * 50
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &b0, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &b0, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &b0, &f0, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &00
	db &f0, &f0, &f0, &f0, &d0, &d0, &70, &30, &f0, &b0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &80
	db &83, &08, &0c, &30, &10, &a0, &f0, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &80
	db &0b, &08, &1c, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &f0, &e0, &f0, &e0, &80
	db &f0, &f0, &f0, &f0, &a0, &a0, &50, &f0, &d0, &f0, &c0, &0f, &08, &00, &30, &f0, &e1, &18, &f0, &00
	db &00, &20, &00, &00, &10, &00, &10, &00, &80, &00, &00, &00, &d0, &f0, &f0, &f0, &c1, &3c, &a0, &00
	db &00, &00, &80, &70, &00, &00, &20, &80, &40, &00, &10, &f0, &f0, &f0, &f0, &f0, &c0, &30, &80, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &10, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &e0, &00, &00, &d0, &00, &00, &00, &00, &00, &00, &10, &f0, &f0, &f0, &f0
	db &f0, &e0, &80, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &00, &00, &00, &00, &10, &d0, &f0, &b0, &f0
	db &f0, &b0, &90, &0f, &0f, &38, &f0, &f0, &f0, &c0, &10, &f0, &f0, &c0, &00, &10, &30, &a1, &0e, &f0
	db &80, &00, &c0, &87, &0f, &0e, &f0, &f0, &f0, &81, &1e, &f0, &f0, &d0, &00, &30, &f0, &61, &78, &f0
	db &0f, &0f, &1c, &30, &a0, &0f, &78, &70, &f0, &f0, &f0, &e1, &68, &78, &00, &10, &c0, &94, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &87, &70, &f0, &f0, &f0, &f0, &87, &1c, &c0, &10, &f0, &a4, &70, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &70, &f0, &f0, &f0, &f0, &c3, &1c, &c0, &10, &f0, &70, &f0, &e1
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &24, &b0, &f0, &f0, &f0, &f0, &84, &80, &00, &f0, &80, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &f0, &f0, &f0, &f0, &f0, &86, &c0, &00, &70, &e0, &03, &0c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &70, &f0, &f0, &f0, &f0, &87, &00, &00, &30, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &08, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &08, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &08, &00, &00, &40, &d0, &30
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &08, &00, &70, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &40, &00, &f0, &84, &0f, &18
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &40, &00, &c1, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &c0, &00, &c3, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &c0, &10, &83, &0e, &00, &83
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &20, &10, &83, &08, &0f, &3c
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &00, &10, &03, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &94, &40, &30, &03, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &20, &10, &07, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &00, &10, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &48, &10, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &60, &00, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &07, &f0, &f0, &f0, &f0, &f0, &87, &48, &21, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &e0, &07, &28, &70, &f0, &f0, &f0, &f0, &87, &00, &21, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &83, &0f, &10, &70, &f0, &f0, &f0, &f0, &c1, &0f, &a0, &21, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &81, &0f, &0e, &50, &f0, &f0, &f0, &f0, &f0, &83, &0e, &c0, &21, &0f, &70, &f0, &f0
	db &f0, &43, &0f, &0f, &0e, &f0, &f0, &f0, &f0, &e0, &0f, &0f, &0f, &3c, &c0, &20, &0f, &78, &f0, &f0
	db &0f, &0b, &1c, &f0, &f0, &f0, &f0, &81, &0f, &0f, &0f, &40, &70, &f0, &00, &20, &0f, &78, &f0, &c3
	db &0f, &0f, &30, &d0, &f0, &f0, &c3, &0f, &0f, &0f, &1e, &b0, &f0, &e0, &00, &20, &0f, &78, &e1, &0f
	db &c0, &60, &30, &10, &80, &f0, &07, &00, &10, &e0, &c0, &00, &00, &00, &00, &10, &0f, &0f, &0f, &0f
	db &00, &00, &00, &00, &d0, &50, &86, &00, &c0, &00, &00, &00, &00, &00, &00, &30, &0f, &0d, &0f, &0f
	db &00, &00, &30, &70, &f0, &f0, &e0, &00, &00, &00, &00, &00, &00, &00, &00, &30, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00

; Tile g_background_12: 8&50 pixels, 2&50 bytes.
g_background_12: ; defs 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &70, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &30, &00, &00, &30, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &00, &00, &70, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &86, &0f, &0e, &70, &c0, &00, &60, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &3c, &c0, &10, &70, &34, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &87, &0b, &0f, &0f, &0f, &0f, &1e, &c3, &34, &c0, &10, &70, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &e1, &0f, &0f, &78, &f0, &e1, &1e, &c0, &00, &70, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &87, &78, &f0, &f0, &f0, &e1, &0e, &c0, &00, &70, &b4, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0, &00, &f0, &34, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0, &00, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &c0, &00, &60, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &c0, &00, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0, &00, &f0, &38, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0, &00, &f0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0c, &c0, &00, &e0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a5, &0c, &c0, &00, &e0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &c0, &00, &e0, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &c0, &00, &70, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &0f, &c0, &00, &60, &0e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &f0, &70, &0f, &3c, &c3, &0f, &1e, &c0, &00, &c1, &0f, &28, &10, &e0, &d0, &b0, &f0, &f0
	db &08, &f0, &d0, &0f, &0f, &0f, &0f, &0f, &1c, &c0, &00, &c1, &0f, &78, &83, &69, &0f, &07, &0f, &0f
	db &04, &07, &0f, &0c, &0f, &1e, &c3, &e0, &70, &80, &00, &50, &87, &0f, &10, &50, &c0, &10, &f0, &f0
	db &0f, &0f, &3c, &c0, &0f, &0f, &0f, &3c, &f0, &00, &00, &70, &92, &0f, &00, &38, &80, &30, &f0, &f0
	db &e0, &b0, &f0, &d0, &f0, &f0, &f0, &e0, &c0, &00, &00, &00, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &70, &70, &f0, &60, &00, &70, &e0, &30, &30, &60, &30, &80, &00, &20, &80, &00, &00, &80, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &80, &00
	db &20, &20, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &80, &00
	db &1e, &00, &0e, &50, &c0, &00, &0f, &0f, &0f, &0f, &08, &10, &60, &01, &0f, &0f, &00, &f0, &c0, &00
	db &0f, &0f, &0f, &0f, &07, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &09, &0f, &0f, &0f, &0f, &f0, &c0, &00
	db &f0, &f0, &f0, &f0, &e1, &0f, &0c, &87, &21, &0d, &0f, &04, &f0, &f0, &f0, &f0, &c3, &70, &e0, &80
	db &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &08, &d0, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0c, &70, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &70, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &3c, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &07, &70, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &78, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &38, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &38, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &18, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1c, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &18, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &0f, &c0

; Tile g_background_13: 8&50 pixels, 2&50 bytes.
g_background_13: ; defs 20 * 50
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0f, &70, &80, &30, &c3, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &0e, &f0, &c0, &30, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &87, &0e, &f0, &80, &30, &c3, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &07, &0e, &f0, &80, &30, &87, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &07, &0f, &f0, &80, &30, &87, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0f, &f0, &80, &30, &87, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0f, &f0, &c0, &30, &07, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0c, &f0, &c0, &30, &0f, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0c, &f0, &00, &30, &0f, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0c, &c0, &00, &30, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &0c, &c0, &00, &30, &c3, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &1e, &80, &00, &30, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &1e, &00, &00, &10, &c1, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &0f, &1e, &80, &00, &00, &e1, &0f, &78, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &07, &1e, &80, &00, &00, &e0, &0f, &b4, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &87, &18, &c0, &00, &00, &e1, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &87, &0c, &c0, &00, &00, &c1, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &87, &38, &c0, &00, &00, &c3, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &83, &38, &f0, &40, &10, &0f, &78, &0f, &0f, &0f, &0f, &78, &90, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &f0, &c0, &10, &07, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &b0
	db &0e, &70, &70, &f0, &f0, &f0, &c3, &3c, &f0, &c0, &50, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &d0
	db &f0, &f0, &e0, &07, &0f, &0f, &0f, &78, &f0, &40, &30, &07, &0f, &10, &f0, &f0, &f0, &f0, &f0, &f0
	db &90, &f0, &80, &f0, &87, &0f, &0f, &70, &f0, &80, &30, &60, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &80, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &40, &20, &30, &00, &00, &00, &40, &f0, &10, &f0, &f0, &f0, &f0, &f0, &f0, &b0, &f0, &f0
	db &00, &10, &80, &b0, &d0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1
	db &00, &30, &f0, &f0, &e0, &b0, &f0, &80, &03, &0d, &0f, &70, &f0, &87, &0f, &3c, &f0, &f0, &f0, &e1
	db &00, &f0, &f0, &f0, &e0, &01, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0e, &78, &f0, &f0
	db &00, &e0, &70, &80, &0d, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &87, &0f, &0f, &0f, &1e, &f0, &f0
	db &00, &f0, &60, &e1, &0f, &41, &0f, &1e, &70, &f0, &f0, &f0, &f0, &c3, &78, &f0, &c3, &0f, &78, &f0
	db &00, &f0, &a0, &07, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &1c, &f0
	db &00, &e0, &21, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &f0
	db &00, &f0, &e1, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &f0
	db &00, &f0, &a0, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &05, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &05, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &04, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &80, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &20, &f0, &80, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &20, &f0, &87, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &00, &f0, &87, &1c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &87, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &87, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &07, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &f0, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &30, &f0, &87, &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &f0, &83, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &10, &e0, &82, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0

; Tile g_background_14: 8&50 pixels, 2&50 bytes.
g_background_14: ; defs 20 * 50
	db &f0, &f0, &e1, &0f, &c0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &e1, &0f, &1c, &f0, &f0, &f0, &f0, &f0, &70, &30, &00, &00, &00, &00, &00, &20, &f0, &f0
	db &f0, &f0, &e1, &c3, &0f, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &00, &10, &f0, &e0, &f0
	db &f0, &f0, &f0, &96, &0f, &1e, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &00, &00, &30, &f0, &e0, &0f
	db &f0, &f0, &f0, &f0, &4b, &0f, &0f, &0f, &0f, &0f, &0f, &38, &b4, &f0, &00, &00, &f0, &f0, &e0, &82
	db &f0, &f0, &f0, &f0, &d2, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &1c, &70, &00, &00, &70, &30, &83, &58
	db &f0, &f0, &f0, &f0, &e1, &68, &30, &f0, &f0, &f0, &f0, &70, &87, &70, &80, &10, &a1, &60, &0f, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &30, &c0, &10, &83, &83, &78, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &30, &c0, &10, &c3, &1c, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &38, &c0, &10, &83, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &38, &c0, &10, &c3, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &70, &c0, &10, &52, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &70, &c0, &10, &92, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &70, &c0, &10, &d2, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &30, &c0, &30, &96, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &82, &70, &c0, &30, &82, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &84, &70, &c0, &30, &07, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a4, &f0, &c0, &30, &07, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &10, &f0, &d0, &f0, &c0, &10, &92, &f0, &f0, &f0
	db &f0, &70, &f0, &0f, &0f, &0f, &0c, &07, &07, &0f, &18, &f0, &48, &f0, &c0, &10, &02, &f0, &f0, &f0
	db &b0, &d2, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &00, &00, &18, &f0, &c0, &10, &12, &f0, &f0, &f0
	db &87, &0f, &0f, &38, &f0, &e0, &07, &0d, &80, &03, &1e, &30, &f0, &b0, &00, &00, &52, &f0, &f0, &f0
	db &07, &28, &1c, &f0, &f0, &f0, &f0, &c0, &f0, &0d, &90, &f0, &f0, &b0, &00, &10, &52, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &e0, &40, &c0, &00, &52, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &06, &f0, &f0, &f0
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &16, &f0, &f0, &f0
	db &f0, &f0, &f0, &d0, &c0, &00, &00, &00, &20, &f0, &f0, &80, &20, &40, &00, &00, &16, &f0, &f0, &f0
	db &78, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &80, &00, &16, &f0, &f0, &f0
	db &0c, &30, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a0, &80, &00, &14, &f0, &f0, &f0
	db &0f, &0d, &0f, &0c, &03, &0b, &0c, &06, &00, &30, &f0, &82, &f0, &90, &00, &00, &34, &f0, &f0, &f0
	db &87, &0f, &0f, &0f, &0f, &07, &0f, &0f, &0f, &0f, &0f, &0f, &0f, &1c, &00, &10, &34, &f0, &f0, &f0
	db &f0, &f0, &e0, &07, &0f, &0f, &78, &f0, &f0, &f0, &e1, &00, &c1, &18, &00, &10, &3c, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &70, &61, &58, &80, &10, &3c, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &3c, &f0, &18, &c0, &00, &3c, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &38, &f0, &08, &80, &00, &38, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &b4, &f0, &0c, &c0, &10, &38, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &92, &b0, &b4, &c0, &01, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c2, &30, &94, &80, &01, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &50, &84, &40, &01, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &18, &b4, &80, &20, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &1c, &f0, &c0, &30, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &1e, &f0, &c0, &20, &70, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &1e, &f0, &c0, &10, &78, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0e, &e0, &80, &10, &0c, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &c0, &00, &10, &0f, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &c0, &00, &10, &43, &78, &f0, &70
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &08, &00, &00, &70, &86, &70, &03
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &48, &00, &00, &30, &84, &81, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &3c, &80, &00, &30, &92, &10, &90
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &3c, &80, &00, &00, &00, &00, &00

; Tile g_background_15: 8&50 pixels, 2&50 bytes.
g_background_15: ; 20 * 50
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &10, &b0, &f0, &40, &70, &e0, &80, &c0, &70, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &c0, &80, &10, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &f0, &f0, &f0, &f0, &f0, &f0, &84, &c0, &0f
	db &18, &f0, &f0, &c0, &80, &0e, &f0, &e0, &10, &0b, &0e, &d2, &87, &0f, &0f, &0f, &0f, &0f, &0f, &0f
	db &20, &03, &0f, &0f, &0c, &07, &0f, &0d, &14, &f0, &a0, &f0, &80, &80, &07, &0f, &0f, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &0e, &f0, &f0, &f0, &f0, &d0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e0, &b4, &e1, &3c, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d2, &c1, &58, &f0, &f0, &f0, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &3c, &f0, &c3, &10, &d0, &40, &00, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &3c, &f0, &c1, &0e, &07, &03, &0f, &0e, &01
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &1e, &f0, &d0, &84, &e0, &60, &0f, &0f, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &70, &80, &00, &00, &00, &30, &84, &80
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &78, &80, &00, &00, &00, &10, &07, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c3, &3c, &00, &00, &00, &00, &00, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0e, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &0f, &00, &00, &00, &00, &00, &00, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &08, &00, &00, &20, &00, &40, &00
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &0f, &68, &00, &00, &f0, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &87, &68, &00, &00, &f0, &f0, &e0, &c0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &83, &78, &00, &10, &f0, &f0, &80, &0d
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &81, &78, &00, &00, &f0, &f0, &83, &0f
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &78, &00, &10, &e0, &e0, &30, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c1, &68, &80, &10, &c0, &16, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &38, &00, &10, &d0, &38, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &08, &00, &10, &f0, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a1, &78, &00, &00, &b0, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &e1, &08, &00, &00, &e0, &78, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &81, &18, &00, &10, &f0, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a1, &0c, &00, &00, &c0, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &a4, &18, &00, &00, &c0, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &18, &00, &00, &c0, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &86, &48, &00, &00, &e1, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &06, &18, &00, &10, &e1, &70, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &d0, &0f, &08, &00, &10, &c1, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &20, &0f, &48, &00, &10, &83, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &b0, &d0, &f0, &80, &00, &87, &0f, &c0, &00, &00, &83, &f0, &f0, &f0
	db &0f, &20, &70, &f0, &c0, &f0, &21, &81, &0f, &0f, &38, &f0, &f0, &00, &00, &20, &83, &f0, &f0, &f0
	db &0f, &0f, &0f, &0c, &38, &87, &0f, &0f, &0d, &1c, &f0, &f0, &90, &00, &00, &20, &c3, &f0, &f0, &f0
	db &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &f0, &c0, &c0, &40, &00, &00, &00, &30, &81, &70, &f0, &f0
	db &00, &00, &00, &00, &00, &c0, &60, &00, &00, &00, &00, &00, &00, &00, &00, &10, &a1, &70, &f0, &f0
