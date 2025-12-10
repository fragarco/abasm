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
; Tile 000
db &AB,&03
db &03,&0C
db &06,&5D
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
; Tile 001
db &03,&57
db &0C,&03
db &AE,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
; Tile 002
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&5D
db &03,&0C
db &AB,&03
; Tile 003
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &AE,&09
db &0C,&03
db &03,&57
; Tile 004
db &AB,&57
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &06,&09
db &AB,&57
; Tile 005
db &AB,&03
db &03,&0C
db &06,&FF
db &06,&FF
db &06,&FF
db &06,&FF
db &03,&0C
db &AB,&03
; Tile 006
db &03,&57
db &0C,&03
db &FF,&09
db &FF,&09
db &FF,&09
db &FF,&09
db &0C,&03
db &03,&57
; Tile 007
db &AB,&57
db &03,&03
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
; Tile 008
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &03,&03
db &AB,&57
; Tile 009
db &03,&03
db &0C,&0C
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &0C,&0C
db &03,&03
; Tile 010
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
db &57,&AB
; Tile 011
db &03,&03
db &03,&03
db &AB,&03
db &AB,&03
db &FF,&03
db &FF,&03
db &FF,&AB
db &FF,&AB
; Tile 012
db &03,&03
db &03,&03
db &03,&57
db &03,&57
db &03,&FF
db &03,&FF
db &57,&FF
db &57,&FF
; Tile 013
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 014
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 015
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 016
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 017
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 018
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 019
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 020
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 021
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 022
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 023
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 024
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 025
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 026
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 027
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 028
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 029
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 030
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 031
db &03,&03
db &03,&03
db &AB,&AB
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 032
db &30,&FF
db &30,&30
db &30,&30
db &30,&FF
db &30,&FF
db &30,&30
db &30,&30
db &30,&FF
; Tile 033
db &FF,&30
db &30,&30
db &30,&30
db &FF,&30
db &FF,&30
db &30,&30
db &30,&30
db &FF,&30
; Tile 034
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 035
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 036
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 037
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 038
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 039
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 040
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 041
db &3F,&3F
db &3F,&BF
db &3F,&FF
db &7F,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 042
db &3F,&3F
db &7F,&3F
db &FF,&7F
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
db &FF,&FF
; Tile 043
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
db &3F,&3F
; Tile 044
db &BD,&3F
db &BD,&3F
db &BD,&3F
db &BD,&3F
db &FC,&3F
db &FC,&3F
db &FC,&3F
db &FC,&3F
; Tile 045
db &3F,&7E
db &3F,&7E
db &3F,&7E
db &3F,&7E
db &3F,&FC
db &3F,&FC
db &3F,&FC
db &3F,&FC
; Tile 046
db &FC,&BD
db &FC,&BD
db &FC,&BD
db &FC,&BD
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; Tile 047
db &7E,&FC
db &7E,&FC
db &7E,&FC
db &7E,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; Tile 048
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
db &FC,&FC
; Tile 049
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
db &F0,&F0
; Tile 050
db &F8,&F0
db &F0,&F0
db &A5,&A5
db &F0,&5A
db &5A,&F0
db &A5,&A5
db &F0,&5A
db &5A,&F0
; Tile 051
db &F0,&F4
db &F0,&F0
db &5A,&5A
db &A5,&F0
db &F0,&A5
db &5A,&5A
db &A5,&F0
db &F0,&A5
; Tile 052
db &5A,&F0
db &F0,&F0
db &5A,&5A
db &A5,&A5
db &00,&F4
db &00,&5E
db &00,&F4
db &F0,&F4
; Tile 053
db &F0,&A5
db &F0,&F0
db &A5,&A5
db &5A,&5A
db &F8,&00
db &AD,&00
db &F8,&00
db &F8,&F0
