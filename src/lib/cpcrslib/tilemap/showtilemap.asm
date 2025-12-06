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

read 'cpcrslib/tilemap/constants.asm'
read 'cpcrslib/tilemap/showtilemap2.asm'

; CPC_SHOWTILEMAP
; Renders the image in the double buffer and
; transfers it to the video memory.
; Inputs:
;     None
; Outputs:
;	  None
;     AF, HL, DE, BC, IX and IY are modified.
cpc_ShowTileMap:
IF (T_HIDDENW + T_HIDDENW) == 0
	xor     a
	ld      (_showt_counter),a
	ld      hl,(_showt_ntiles)
	ld      (_showt_counter2),hl
	ld      hl,tiles_bgmap
	call    _showt_fill_doublebuffer
	; now that we have the doublebuffer ready
	; we move the image to the video memory
	ld      hl,T_DOUBLEBUFFER_ADDR
	push    hl
	ld      (__showt_visiblescr_start_sb+1),HL
	ld      b,T_WSIZE_BYTES - 4 * T_HIDDEN_W0
	ld      c,T_HSIZE_BYTES - 16 * T_HIDDEN_H0
	ld      hl,tiles_videomemory_lines
	ld      e,(hl)
	inc     hl
	ld      d,(hl)
	ex      de,hl
	ld      (__showt_visiblescr_start2+1),hl
	pop     de
	jp      _showt_create_scans
ELSE
	xor     a
	ld      (_showt_counter),a
	ld      hl,(_showt_ntiles)
	ld      (_showt_counter2),hl
	ld      hl,tiles_bgmap
	call    _showt_fill_doublebuffer
	; now that we have the doublebuffer ready
	; we move the image to the video memory
	ld      de,T_DOUBLEBUFFER_ADDR
	ld      hl,T_HIDDEN_W0 * 2
	add     hl,de
	ld      de,T_WSIZE_BYTES
	ld      b,T_HIDDEN_H0 * 8
	xor     a
	cp      b
	jr      z,__showt_skip_loop
__showt_visibleh_loop:
	add     hl,de
	djnz    __showt_visibleh_loop
__showt_skip_loop:
	push    hl
	ld      (__showt_visiblescr_start_sb+1),hl
	ld      b,T_WSIZE_BYTES - 4 * T_HIDDEN_W0
	ld      c,T_HSIZE_BYTES - 16 * T_HIDDEN_H0
	ld      de,T_HIDDEN_H0 * 2
	ld      hl,tiles_videomemory_lines
	add     hl,de
	ld      e,(hl)
	inc     hl
	ld      d,(hl)
	ld      hl,2 * T_HIDDEN_W0
	add     hl,de
	ld      (__showt_visiblescr_start2+1),hl
	pop     de
	jp      _showt_create_scans
ENDIF


; PRIVATE ROUTINE
;
_showt_fill_doublebuffer:
	push    hl
	pop     ix
	ld      de,(tiles_doblebuffer_lines)
__fillbkg_loop:
	ld      l,(ix+0)
	ld      h,0
	add     hl,hl
	add     hl,hl
	add     hl,hl
	add     hl,hl   ; x16
	ld      bc,tiles_tilearray
	add     hl,bc	; HL points to the tile to transfer
	ex      de,hl   ; DE points to source
	push    hl		; HL point to line in the doublebuffer
	call    _showt_moveto_doublebuffer 

	ld      hl,(_showt_counter2)
	dec     hl
	ld      (_showt_counter2),hl
	ld      a,h
	or      l
	jr      z,__showt_filldb_return
	pop     hl
	inc     ix	     ; next byte
	ex      de,hl
	ld      a,(_showt_counter)
	cp      T_WIDTH-1 
	jr      z,__showt_filldb_inc
	inc     a
	ld      (_showt_counter),a
	inc     de        ; next position
	inc     de	      
	jr      __fillbkg_loop
__showt_filldb_inc:
	xor     a
	ld      (_showt_counter),a
	ld      bc,7 * T_WSIZE_BYTES + 2 
	ex      de,hl
	add     hl,bc
	ex      de,hl
	jr      __fillbkg_loop
__showt_filldb_return:
	pop     hl
	ret

_showt_counter:  db 0
_showt_counter2: dw 0
_showt_ntiles:   dw T_HEIGHT * T_WIDTH

; PRIVATE ROUTINE
;
_showt_moveto_doublebuffer:
	ld      bc,T_WSIZE_BYTES - 1 
	db      &FD     ; Extended IY opcode
   	ld      h,8
__moveto_height_loop:
__moveto_width_loop:
	ld      a,(de)
	ld      (hl),a
	inc     de
	inc     hl
	ld      a,(de)
	ld      (hl),a
	inc     de
	db      &FD     ; Extended IY opcode
	dec     h
	ret     z
	; We add the screen width in bytes to jump to the next line
	add     hl,bc
	jr      __moveto_height_loop
