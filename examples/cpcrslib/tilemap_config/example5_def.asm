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

; Top-Left screen value where Tile Map will be shown.
T_VIDEOMEMORY_ADDR   equ &C0AC
; Memory location where the double buffer (aka superbuffer) that composes the
; Tile Map (or superbuffer) starts. This buffer consumes T_WIDTH * 2 + T_HEIGHT * 8 bytes.
T_DOUBLEBUFFER_ADDR  equ &0100

;----------------------------------------------------------------------------------------
; TILE MAP DIMENSIONS
;----------------------------------------------------------------------------------------
; Video memory 640x200 bits arreged depending on video mode.
T_WIDTH  equ 28 	; Width of screen in Tiles. Max = 40 (40*2 = 80 * 8 = 640 bits)
T_HEIGHT equ 14		; Heigh of screen in Tiles. Max = 20 (20*8 = 160 bits + 40 bits of margin)

; Invisible tile margins (in tiles). 
; This area is not shown on the screen. It can be used to make the sprites appear or disappear
; of the screen.

T_HIDDENW equ 2		; Number of horizontal hidden tiles 		
T_HIDDENH equ 0		; Number of vertical hidden tiles 

;----------------------------------------------------------------------------------------
; Transparent colour for cpc_PutTrSpTileMap2b routine
; for printing sprites using transparent color a mask color selection is 
; requiered. The color is defined through two bytes using the screen mode
; arrangement.
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

T_MASK1 equ 0
T_MASK2 equ 0

;------------------------------------------------------------------------------------
; TILE DATA. TILES MUST BE DEFINED HERE!
;------------------------------------------------------------------------------------

tiles_tilearray: ; Each tile is 2 x 8 bytes
; subb000,
db &AB,&03
db &03,&0C
db &06,&5D
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
; subb001,
db &03,&57
db &0C,&03
db &AE,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
; subb002,
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&5D
db &03,&0C
db &AB,&03
; subb003,
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &AE,&09
db &0C,&03
db &03,&57
; subb004,
db &AB,&57
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &AB,&57
; subb005,
db &AB,&03
db &03,&0C
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &03,&0C
db &AB,&03
; subb006,
db &03,&57
db &0C,&03
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &0C,&03
db &03,&57
; subb007,
db &AB,&57
db &03,&03
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
; subb008,
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &03,&03
db &AB,&57
; subb009,
db &03,&03
db &0C,&0C
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &0C,&0C
db &03,&03
; subb010,
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
; subb011,
db &03,&03
db &03,&03
db &AB,&03
db &AB,&03
db &FF,&03
db &FF,&03
db &FF,&AB
db &FF,&AB
; subb012,
db &03,&03
db &03,&03
db &03,&57
db &03,&57
db &03,&FF
db &03,&FF
db &57,&FF
db &57,&FF
; subb013,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb014,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb015,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb016,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb017,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb018,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb019,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb020,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb021,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb022,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb023,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb024,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb025,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb026,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb027,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb028,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb029,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb030,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb031,
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb032,
db &30,&FF
db &30,&30
db &30,&30
db &30,&FF
db &30,&FF
db &30,&30
db &30,&30
db &30,&FF
; subb033,
db &FF,&30
db &30,&30
db &30,&30
db &FF,&30
db &FF,&30
db &30,&30
db &30,&30
db &FF,&30
; subb034,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb035,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb036,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb037,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb038,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb039,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb040,
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb041,
db &3F,&3F
db &3F,&BF
db &3F,&FF
db &7F,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb042,
db &3F,&3F
db &7F,&3F
db &FF,&7F
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; subb043,
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; subb044
db &BD,&3F
db &BD,&3F
db &BD,&3F
db &BD,&3F
db &FC,&3F
db &FC,&3F
db &FC,&3F
db &FC,&3F
; subb045
db &3F,&7E
db &3F,&7E
db &3F,&7E
db &3F,&7E
db &3F,&FC
db &3F,&FC
db &3F,&FC
db &3F,&FC
; subb046
db &FC,&BD
db &FC,&BD
db &FC,&BD
db &FC,&BD
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; subb047
db &7E,&FC
db &7E,&FC
db &7E,&FC
db &7E,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; subb048
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; subb049
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
; subb050
db &F8,&F0
db &F0,&F0
db &A5,&A5
db &F0,&5A
db &5A,&F0
db &A5,&A5
db &F0,&5A
db &5A,&F0

db &F0,&F4
db &F0,&F0
db &5A,&5A
db &A5,&F0
db &F0,&A5
db &5A,&5A
db &A5,&F0
db &F0,&A5

db &5A,&F0
db &F0,&F0
db &5A,&5A
db &A5,&A5
db &00,&F4
db &00,&5E
db &00,&F4
db &F0,&F4

db &F0,&A5
db &F0,&F0
db &A5,&A5
db &5A,&5A
db &F8,&00
db &AD,&00
db &F8,&00
db &F8,&F0
