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

; This file defines some constants and lookup tables that speed up the
; routines related to tilemaps.
; This constants use values defined in the tilemap_def.asm file that users
; muest configure and import in their projects.

;----------------------------------------------------------------------------------------
; Other parameters (internal use)
;----------------------------------------------------------------------------------------

T_HIDDEN_W0     equ T_HIDDENW
T_HIDDEN_H0     equ T_HIDDENH
T_HIDDEN_W1     equ T_WIDTH - T_HIDDENW - 1
T_HIDDEN_H1     equ T_HEIGHT - T_HIDDENH - 1
T_WSIZE_BYTES   equ 2 * T_WIDTH 	
T_HSIZE_BYTES   equ 8 * T_HEIGHT
T_WSIZE_VISIBLEBYTES equ 2 * T_WIDTH

;------------------------------------------------------------------------------------
; Table for the screen position of the tiles (Left Column)
;------------------------------------------------------------------------------------

tiles_videomemory_lines:
    dw T_VIDEOMEMORY_ADDR + &50 * 0
    dw T_VIDEOMEMORY_ADDR + &50 * 1
    dw T_VIDEOMEMORY_ADDR + &50 * 2
    dw T_VIDEOMEMORY_ADDR + &50 * 3
    dw T_VIDEOMEMORY_ADDR + &50 * 4
    dw T_VIDEOMEMORY_ADDR + &50 * 5
    dw T_VIDEOMEMORY_ADDR + &50 * 6
    dw T_VIDEOMEMORY_ADDR + &50 * 7
    dw T_VIDEOMEMORY_ADDR + &50 * 8
    dw T_VIDEOMEMORY_ADDR + &50 * 9
    dw T_VIDEOMEMORY_ADDR + &50 * 10
    dw T_VIDEOMEMORY_ADDR + &50 * 11
    dw T_VIDEOMEMORY_ADDR + &50 * 12
    dw T_VIDEOMEMORY_ADDR + &50 * 13
    dw T_VIDEOMEMORY_ADDR + &50 * 14
    dw T_VIDEOMEMORY_ADDR + &50 * 15
    dw T_VIDEOMEMORY_ADDR + &50 * 16
    dw T_VIDEOMEMORY_ADDR + &50 * 17
    dw T_VIDEOMEMORY_ADDR + &50 * 18
    dw T_VIDEOMEMORY_ADDR + &50 * 19

;------------------------------------------------------------------------------------
; Table for the Supperbuffer position of the tiles (Left Column)
;------------------------------------------------------------------------------------

tiles_doblebuffer_lines:			
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 0
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 1
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 2
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 3
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 4
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 5
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 6
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 7
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 8
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 9
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 10
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 11
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 12
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 13
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 14
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 15
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 16
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 17
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 18
    dw T_DOUBLEBUFFER_ADDR + 8 * T_WSIZE_BYTES * 19

;------------------------------------------------------------------------------------

tiles_current_screen:  dw 0
tiles_game_screen:
    defs T_WIDTH * T_HEIGHT
    db   &FF	    ; End of screen mark.
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
