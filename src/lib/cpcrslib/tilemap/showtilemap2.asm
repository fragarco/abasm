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

; CPC_SHOWTILEMAP2
; Renders the image in the double buffer and transfers it to the video memory.
; This is a different version than cpc_ShowTileMap
; Inputs:
;     None
; Outputs:
;	  None
;     AF, HL, DE, BC, IX and IY are modified.
cpc_ShowTileMap2:
IF (T_HIDDENW + T_HIDDENW) == 0
	ld      bc,256 * (T_WSIZE_BYTES - 4 * T_HIDDEN_W0) + T_HSIZE_BYTES - 16 * T_HIDDEN_H0
__showt_visiblescr_start:
	ld      hl,0
__showt_visiblescr_start_sb:
	ld      hl,0
	di
	ld	    (__showt_spvalue),sp
	ld	    sp,_showtiles_scantable
	ld	    a,T_HSIZE_BYTES
__showt_ppv0:
	pop	    de
__showt_ldi_jumpstart:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
__showt_ldi_next:
	dec     a
	jp      nz, __showt_ppv0
	ld	    sp,(__showt_spvalue)
	ei
	ret

; PRIVATE ROUTINE
;
_showt_create_scans:
	ld	     ix,_showtiles_scantable
__showt_visiblescr_start2:
	ld	     hl,0
	ld	     b,T_HEIGHT	; number of files
__cts0_loop:
	push	 bc
	push	 hl
	ld	     b,8
	ld	     de,2048
__cts1_loop:
	ld	     (ix+0),l
	inc	     ix
	ld	     (ix+0),h
	inc	     ix
	add	     hl,de
	djnz	 __cts1_loop
	pop	     hl
	ld	     bc,80
	add	     hl,bc
	pop	     bc
	djnz	 __cts0_loop
__scan_preapre_ldijump:
	ld       hl,T_WSIZE_BYTES
	ld       de,__showt_ldi_jumpstart
	add      hl,hl
	add      hl,de
	ld       (hl),&C3
	inc      hl
	ld       de,__showt_ldi_next
	ld       (hl),e
	inc      hl
	ld       (hl),d
	ret
	
ELSE

; cpc_ShowTileMap2:
	ld      bc,256 * (T_WSIZE_BYTES - 4 * T_HIDDEN_W0) + T_HSIZE_BYTES - 16 * T_HIDDEN_H0
__showt_visiblescr_start:
	ld      hl,0
__showt_visiblescr_start_sb:
	ld      hl,0
	di
	ld	    (__showt_spvalue),sp
	ld	    sp,_showtiles_scantable
	ld	    a,T_HSIZE_BYTES - 16 * (T_HIDDEN_H0)
__showt_ppv0:
	pop	    de		; va recogiendo de la pila!!
__showt_ldi_jumpstart:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
__showt_ldi_next:
	ld      de,4 * T_HIDDEN_W0
	add	    hl,de
__showt_ldi_next1:
	dec     a
	jp      nz,__showt_ppv0
	ld      sp,(__showt_spvalue)
	ei
	ret

; PRIVATE ROUTINE
;
_showt_create_scans:
	ld      ix,_showtiles_scantable
__showt_visiblescr_start2:
	ld      hl,0
	ld      b,T_HEIGHT - 2 * T_HIDDEN_H0
__cts0_loop:
	push	bc
	push	hl
	ld	    b,8
	ld	    de,2048
__cts1_loop:
	ld	    (ix+0),l
	inc	    ix
	ld	    (ix+0),h
	inc	    ix
	add	    hl,de
	djnz    __cts1_loop
	pop	    hl
	ld      bc,80
	add	    hl,bc
	pop	    bc
	djnz    __cts0_loop
__scan_preapre_ldijump:
	ld      hl,T_WSIZE_BYTES - 4 * T_HIDDEN_W0
	ld      de,__showt_ldi_jumpstart
	add     hl,hl
	add     hl,de
	ld      (hl),&C3
	inc     hl
	ld      de,__showt_ldi_next
	ld      (hl),e
	inc     hl
	ld      (hl),d
	ret

ENDIF

__showt_spvalue: dw	0
_showtiles_scantable: defs 20*16
