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

org &4000
jp main

;;----------------------------------------------------
;; Definition of DATA structures and constants
;;----------------------------------------------------

;; Useful constants
CPCT_VMEM_START equ &C000

;;
;; Macro: struct Player
;;    Macro that creates a new initialized instance of Player Struct
;; 
;; Parameters:
;;    instanceName: name of the variable that will be created as an instance of Player struct
;;    st:           status of the player
;;    px:           X location of the Player (bytes)
;;    py:           Y location of the Player (pixels)
;;    wi:           Width of the Player Sprite (bytes)
;;    he:           Height of the Player Sprite (bytes)
;;    sprite:       Pointer to the player sprite
;;
macro definePlayer instanceName, _st_, _px_, _py_, _wi_, _he_, _sprite_
   ;; Struct data
   instanceName:
      instanceName_status: db _st_     ;; Status of the Player
      instanceName_x_pos:  db _px_     ;; X location of the Player (bytes)
      instanceName_y_pos:  db _py_     ;; Y location of the Player (pixels)
      instanceName_width:  db _wi_     ;; Width of the Player Sprite (bytes)
      instanceName_height: db _he_     ;; Height of the Player Sprite (bytes)
      instanceName_sprite: dw _sprite_ ;; Pointer to the player sprite
endm

;;
;; Macro: struct Player offsets
;;
;;    Macro that generates offsets for accessing different elements of 
;; the Player struct (distances from the start of the struct to each
;; struct member). Requires a already defined instance as an example for
;; calculating offsets.
;;
;; Parameters:
;;    stname:        Name of the structure
;;    instanceName:  Name of the instance that will be used to calculate offsets
;;
macro definePlayerOffsets stname, instanceName
   ;; Offset constants
   stname_status_off equ instanceName_status - instanceName ;; status offset
   stname_x_pos_off  equ instanceName_x_pos  - instanceName ;; X offset
   stname_y_pos_off  equ instanceName_y_pos  - instanceName ;; Y offset
   stname_width_off  equ instanceName_width  - instanceName ;; Width offset
   stname_height_off equ instanceName_height - instanceName ;; Height offset
   stname_sprite_off equ instanceName_sprite - instanceName ;; Sprite offset
endm

;;------------------------------------------------------------
;; Definition of data elements
;;------------------------------------------------------------

;; Definition of Players
definePlayer ryu, 0, 58, 60, 21, 81, _g_sprite_ryu
definePlayer ken, 0,  0, 60, 21, 81, _g_sprite_ken
definePlayerOffsets player, ryu 

;; import the CPCtelera functions we want to use
read 'cpctelera/firmware/cpct_removeInterruptHandler.asm'
read 'cpctelera/video/cpct_getScreenPtr.asm'
read 'cpctelera/sprites/cpct_drawSprite.asm'
read 'cpctelera/video/cpct_setVideoMode.asm'

;;-----------------------------------------------
;; Draw a player
;;    IX = player struct pointer
;;-----------------------------------------------
drawPlayer:
   ;; Get Screen Pointer
   ld  de, CPCT_VMEM_START        ;; DE = Pointer to video memory start
   ld  c, (ix + player_x_pos_off) ;; C  = Player X Position
   ld  b, (ix + player_y_pos_off) ;; B  = Player Y Position
   call cpct_getScreenPtr         ;; Get Screen Pointer
   ;; Return value: HL = Screen Pointer to (X, Y) byte

   ;; Draw Sprite
   ex  de, hl                           ;; DE = Pointer to Video Memory (X,Y) location
   ld   h, (ix + player_sprite_off + 1) ;; | HL = Pointer to Player Sprite
   ld   l, (ix + player_sprite_off + 0) ;; |
   ld   c, (ix + player_width_off)      ;; C = Player Width (bytes)
   ld   b, (ix + player_height_off)     ;; B = Player Height (pixels)
   call cpct_drawSprite                 ;; Draw the sprite
   ret

;;-----------------------------------------------
;; MAIN function. This is the entry point of the application.
;;-----------------------------------------------
main:
   ;; Initialize CPC
   call cpct_disableFirmware    ;; Disable Firmware
   ld  c, 0                     ;; C = 0 (Mode 0)
   call cpct_setVideoMode       ;; Set Mode 0

   ;; Draw RYU and KEN
   ld  ix, ryu                   ;; IX = Pointer to Ryu structure
   call drawPlayer               ;; Draw RYU Player
   ld  ix, ken                   ;; IX = Pointer to Ken structure
   call drawPlayer               ;; Draw Ken Player

   ;; Infinite waiting loop
forever:
   jp forever


; Data created with Img2CPC - (c) Retroworks - 2007-2017
; Tile g_sprite_ryu: 42x81 pixels, 21x81 bytes.
_g_sprite_ryu: ; defs 21 * 81
	db &00, &00, &00, &00, &00, &00, &00, &00, &e4, &a0, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &e4, &cc, &f0, &88, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &e4, &cc, &d8, &e4, &cc, &8a, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &50, &cc, &d8, &e5, &cc, &d8, &cd, &00, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &e4, &ce, &e5, &cf, &ce, &f0, &e4, &8a, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &e4, &d8, &d8, &cc, &e5, &f0, &b0, &cc, &8d, &30, &30, &20, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &f0, &d8, &cc, &e4, &c8, &f0, &e4, &64, &30, &cc, &cc, &98, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &f0, &cd, &da, &cd, &cf, &e5, &98, &4e, &64, &cc, &cc, &cc, &20, &00, &00, &00
	db &00, &00, &00, &00, &00, &50, &f0, &f0, &60, &cc, &ca, &30, &8d, &64, &cc, &ce, &cc, &25, &00, &00, &00
	db &00, &00, &00, &00, &00, &50, &52, &ce, &c5, &ce, &ca, &25, &98, &64, &ca, &c5, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &a0, &cc, &c5, &ce, &9a, &64, &0f, &64, &cd, &c5, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &44, &cd, &cc, &98, &4e, &25, &cc, &cd, &cf, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &44, &ce, &c5, &cc, &30, &8d, &30, &cc, &cf, &ce, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cd, &4e, &d8, &f0, &25, &98, &30, &cd, &ca, &c5, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cf, &64, &cd, &cc, &f0, &1a, &64, &cc, &cc, &cf, &cc, &98, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &ca, &64, &d0, &cc, &d8, &f0, &e5, &cf, &cf, &cd, &ce, &8d, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cd, &64, &d0, &cc, &d8, &cc, &c8, &c0, &c5, &cf, &ce, &8d, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cd, &64, &ca, &f0, &e4, &cc, &ca, &c0, &c0, &cf, &cc, &cc, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cc, &64, &cc, &da, &f0, &cc, &ca, &c0, &c5, &ce, &cc, &4e, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cc, &64, &cc, &cc, &f0, &f0, &cd, &cf, &cf, &ce, &cc, &4e, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &cc, &64, &cc, &98, &cc, &f0, &cc, &cd, &cf, &cc, &8d, &cc, &00, &00, &00
	db &00, &00, &00, &00, &00, &44, &ce, &64, &cc, &1a, &8d, &64, &cc, &cc, &cc, &cc, &8d, &cc, &00, &00, &00
	db &00, &00, &00, &00, &00, &44, &c5, &98, &cc, &30, &98, &30, &64, &cc, &cd, &ce, &4e, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &44, &ca, &cc, &64, &30, &98, &30, &30, &4e, &cc, &cc, &4e, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &44, &cf, &cc, &cc, &1a, &98, &30, &30, &30, &30, &25, &cc, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &44, &cc, &cc, &cc, &8d, &8d, &30, &30, &30, &30, &4e, &cc, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &ca, &ce, &e4, &cc, &8d, &cc, &1a, &30, &30, &0f, &cc, &88, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &cf, &cc, &d8, &03, &e4, &cc, &cc, &0f, &4e, &cc, &cc, &88, &00, &00, &00, &00
	db &00, &00, &00, &00, &ce, &cc, &cc, &c5, &cc, &f0, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cf, &cc, &c8, &cc, &cd, &cc, &f0, &cc, &1a, &25, &cc, &f0, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cf, &e4, &c8, &c5, &cc, &cc, &d8, &f0, &f0, &f0, &f0, &e4, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &f0, &e5, &cc, &cc, &cc, &4e, &f0, &f0, &f0, &8d, &64, &88, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &d8, &e0, &cf, &cc, &4e, &25, &d8, &f0, &8d, &30, &8d, &cc, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &cc, &f0, &ce, &98, &25, &98, &d8, &d8, &98, &4e, &1a, &64, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &cc, &98, &30, &4e, &d8, &5a, &e4, &8d, &30, &98, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &8d, &30, &25, &f0, &d8, &e4, &1a, &30, &98, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &cc, &1a, &30, &f0, &d8, &b0, &30, &30, &cc, &20, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &cc, &cc, &30, &f0, &70, &b0, &30, &30, &cc, &20, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &44, &cc, &cc, &8d, &f0, &70, &b0, &30, &30, &cc, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &44, &cc, &cc, &cc, &f0, &70, &b0, &30, &64, &98, &88, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &44, &cc, &8d, &4e, &f0, &d8, &e4, &cc, &cc, &30, &0a, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &cc, &cc, &0f, &30, &f0, &d8, &e4, &cc, &98, &30, &64, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &cc, &cc, &1a, &30, &f0, &d8, &e4, &cc, &30, &30, &25, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &cc, &8d, &1a, &30, &f0, &d8, &e4, &8d, &30, &30, &25, &88, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &cc, &8d, &30, &30, &f0, &d8, &cc, &0f, &30, &30, &30, &88, &00, &00
	db &00, &00, &00, &00, &00, &00, &44, &8d, &8d, &30, &30, &70, &cc, &cc, &0f, &30, &30, &30, &0a, &00, &00
	db &00, &00, &00, &00, &00, &00, &44, &8d, &8d, &30, &30, &25, &cc, &cc, &0f, &1a, &30, &30, &4e, &00, &00
	db &00, &00, &00, &00, &00, &00, &44, &8d, &8d, &30, &30, &25, &cc, &cc, &0f, &1a, &30, &30, &64, &00, &00
	db &00, &00, &00, &00, &00, &00, &44, &98, &0f, &30, &30, &64, &cc, &cc, &8d, &0f, &30, &30, &25, &00, &00
	db &00, &00, &00, &00, &00, &00, &cc, &98, &0f, &30, &30, &4e, &88, &cc, &cc, &0f, &30, &30, &25, &88, &00
	db &00, &00, &00, &00, &00, &00, &cc, &98, &25, &30, &30, &4e, &88, &cc, &cc, &8d, &1a, &30, &30, &88, &00
	db &00, &00, &00, &00, &00, &00, &cc, &98, &30, &30, &25, &cc, &00, &44, &cc, &cc, &1a, &30, &30, &0a, &00
	db &00, &00, &00, &00, &00, &44, &cc, &98, &30, &30, &25, &cc, &00, &00, &cc, &cc, &8d, &30, &30, &0a, &00
	db &00, &00, &00, &00, &00, &44, &cc, &98, &30, &30, &4e, &88, &00, &00, &44, &cc, &8d, &30, &30, &0a, &00
	db &00, &00, &00, &00, &00, &cc, &8d, &98, &30, &25, &cc, &88, &00, &00, &44, &cc, &1a, &1a, &1a, &0a, &00
	db &00, &00, &00, &00, &00, &cc, &8d, &98, &30, &64, &4e, &00, &00, &00, &cc, &8d, &4e, &1a, &98, &0a, &00
	db &00, &00, &00, &00, &44, &cc, &8d, &1a, &30, &1a, &cc, &00, &00, &00, &cc, &4e, &cc, &64, &98, &0a, &00
	db &00, &00, &00, &00, &44, &cc, &8d, &0f, &25, &64, &88, &00, &00, &00, &cc, &cc, &8d, &4e, &1a, &88, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &30, &0f, &cc, &88, &00, &00, &00, &8d, &4e, &98, &cc, &25, &88, &00
	db &00, &00, &00, &00, &cc, &cc, &4e, &8d, &0f, &cc, &00, &00, &00, &44, &8d, &cc, &0f, &8d, &25, &00, &00
	db &00, &00, &00, &44, &cc, &8d, &1a, &0f, &4e, &88, &00, &00, &00, &44, &cc, &cc, &64, &98, &4e, &00, &00
	db &00, &00, &00, &44, &cc, &0f, &30, &30, &4e, &88, &00, &00, &00, &cc, &cc, &8d, &cc, &1a, &4e, &00, &00
	db &00, &00, &00, &cc, &8d, &1a, &30, &30, &cc, &00, &00, &00, &00, &cc, &cc, &4e, &8d, &25, &0a, &00, &00
	db &00, &00, &00, &cc, &0f, &30, &30, &64, &cc, &00, &00, &00, &44, &cc, &0f, &8d, &1a, &25, &88, &00, &00
	db &00, &00, &00, &05, &1a, &30, &30, &cc, &88, &00, &00, &00, &44, &cc, &cc, &0f, &30, &0f, &88, &00, &00
	db &00, &00, &00, &44, &1a, &30, &25, &cc, &88, &00, &00, &00, &44, &cc, &8d, &1a, &30, &4e, &00, &00, &00
	db &00, &00, &00, &00, &1a, &30, &64, &cc, &00, &00, &00, &00, &cc, &8d, &0f, &30, &25, &4e, &00, &00, &00
	db &00, &00, &00, &44, &1a, &30, &cc, &88, &00, &00, &00, &00, &44, &0f, &30, &30, &25, &88, &00, &00, &00
	db &00, &00, &00, &cc, &98, &25, &4e, &00, &00, &00, &00, &00, &00, &98, &30, &30, &25, &88, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &25, &88, &00, &00, &00, &00, &00, &00, &cc, &30, &30, &0f, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &44, &cc, &8d, &30, &4e, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cf, &cc, &00, &00, &00, &00, &00, &00, &44, &cf, &cf, &cc, &00, &00, &00, &00, &00
	db &00, &00, &00, &cd, &cf, &ce, &00, &00, &03, &03, &03, &03, &cd, &c5, &c5, &ce, &00, &00, &00, &00, &00
	db &00, &00, &44, &cd, &c0, &c5, &89, &03, &03, &03, &03, &03, &46, &cc, &c0, &c5, &88, &00, &00, &00, &00
	db &00, &00, &44, &cf, &c5, &cf, &89, &03, &03, &03, &03, &03, &03, &46, &cf, &cf, &cc, &88, &00, &00, &00
	db &00, &03, &46, &cf, &cf, &c0, &89, &03, &03, &03, &03, &03, &03, &46, &c5, &cc, &cc, &cc, &89, &02, &00
	db &03, &03, &46, &cc, &cc, &cd, &89, &03, &03, &03, &03, &03, &03, &46, &ca, &c0, &cd, &cd, &89, &03, &02
	db &03, &03, &46, &ce, &ce, &cf, &89, &03, &03, &03, &03, &03, &03, &03, &cc, &cf, &cc, &cc, &89, &03, &03
	db &03, &03, &46, &cc, &cc, &cc, &03, &03, &03, &03, &03, &03, &03, &03, &03, &cc, &03, &03, &03, &03, &03
	db &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &02
	db &00, &01, &03, &03, &03, &03, &02, &00, &00, &00, &00, &00, &00, &00, &03, &03, &03, &03, &03, &00, &00
; Data created with Img2CPC - (c) Retroworks - 2007-2017
; Tile g_sprite_ken: 42x81 pixels, 21x81 bytes.
_g_sprite_ken:  ; defs 21 * 81
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &50, &d0, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &10, &f0, &c0, &d0, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &10, &30, &70, &e0, &c0, &d0, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &00, &30, &b0, &30, &70, &e0, &c0, &a0, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &00, &00, &00, &10, &70, &f0, &30, &30, &70, &c0, &d0, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &70, &f0, &da, &30, &b0, &e0, &d0, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &d8, &f0, &c4, &d8, &30, &e0, &f0, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &da, &cf, &ce, &b0, &60, &f0, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cd, &cc, &cc, &cc, &cc, &c5, &cc, &c4, &f0, &f0, &a0, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &ca, &c5, &cc, &cc, &cc, &c5, &cd, &ca, &cd, &a1, &a0, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &ca, &ce, &cc, &cc, &cc, &cd, &cd, &ca, &cc, &50, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cf, &ce, &cc, &cc, &cc, &cc, &cc, &ce, &88, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cd, &cf, &cc, &cc, &cc, &cc, &cc, &ca, &cd, &88, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &ca, &c5, &ce, &cc, &cc, &cc, &f0, &e4, &cc, &ce, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cf, &cc, &cc, &cc, &cc, &f0, &30, &ce, &cc, &cf, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cd, &ce, &cf, &cf, &da, &f0, &b0, &30, &e0, &cc, &c5, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cd, &cf, &ca, &c0, &90, &30, &b0, &30, &e0, &cc, &ce, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cf, &c0, &c0, &c5, &30, &70, &f0, &c5, &cc, &ce, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cd, &ca, &c0, &c5, &30, &f0, &e5, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cd, &cf, &cf, &ce, &f0, &f0, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cf, &ce, &cc, &f0, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cd, &88, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cd, &ce, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &ca, &88, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &c5, &88, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cf, &88, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &d8, &65, &c5, &00, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &d8, &03, &b0, &30, &cf, &20, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &f0, &cc, &ca, &30, &30, &65, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &f0, &cc, &cc, &cc, &cc, &f0, &cc, &ce, &cc, &90, &30, &cf, &00, &00, &00, &00
	db &00, &00, &00, &00, &00, &d8, &f0, &f0, &f0, &f0, &e4, &cc, &cc, &ca, &90, &70, &cf, &00, &00, &00, &00
	db &00, &00, &00, &00, &44, &cc, &cc, &f0, &f0, &f0, &cc, &cc, &cc, &cc, &da, &f0, &cc, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &f0, &e4, &cc, &cc, &cc, &cf, &d0, &e4, &88, &00, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &e4, &e4, &cc, &cc, &cc, &cd, &f0, &cc, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &e4, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &d8, &e4, &f0, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &e4, &f0, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &e4, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &44, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &44, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &88, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &88, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00
	db &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00
	db &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00
	db &00, &00, &44, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &88, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &44, &cc, &cc, &cc, &cc, &88, &00, &00, &00
	db &00, &00, &00, &cc, &cc, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &cc, &cc, &cc, &cc, &00, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &44, &cc, &cc, &cc, &88, &00, &00, &00
	db &00, &00, &00, &44, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &cc, &cc, &cc, &cc, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &00, &00, &00, &00, &00, &00, &44, &cc, &cc, &cc, &00, &00, &00
	db &00, &00, &00, &00, &cc, &cc, &cc, &cc, &88, &00, &00, &00, &00, &00, &44, &cc, &cc, &cc, &00, &00, &00
	db &00, &00, &00, &00, &00, &cc, &cf, &cf, &88, &00, &00, &00, &00, &00, &00, &cc, &cf, &cc, &00, &00, &00
	db &00, &00, &00, &00, &00, &cd, &ca, &ca, &ce, &03, &03, &03, &03, &00, &00, &cd, &cf, &ce, &00, &00, &00
	db &00, &00, &00, &00, &44, &ca, &c0, &cc, &89, &03, &03, &03, &03, &03, &46, &ca, &c0, &ce, &88, &00, &00
	db &00, &00, &00, &44, &cc, &cf, &cf, &89, &03, &03, &03, &03, &03, &03, &46, &cf, &ca, &cf, &88, &00, &00
	db &00, &01, &46, &cc, &cc, &cc, &ca, &89, &03, &03, &03, &03, &03, &03, &46, &c0, &cf, &cf, &89, &03, &00
	db &01, &03, &46, &ce, &ce, &c0, &c5, &89, &03, &03, &03, &03, &03, &03, &46, &ce, &cc, &cc, &89, &03, &03
	db &03, &03, &46, &cc, &cc, &cf, &cc, &03, &03, &03, &03, &03, &03, &03, &46, &cf, &cd, &cd, &89, &03, &03
	db &03, &03, &03, &03, &03, &cc, &03, &03, &03, &03, &03, &03, &03, &03, &03, &cc, &cc, &cc, &89, &03, &03
	db &01, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03, &03
    db &00, &00, &03, &03, &03, &03, &03, &00, &00, &00, &00, &00, &00, &00, &01, &03, &03, &03, &03, &02, &00
