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

; CPC_PRINT
; Prints a null-terminated string using a custom font and direct
; hardware access in the video memory indicated (ONLY MODE 1).
; Requires a designed custom font like the example provided in
; nanako_font.asm
; Inputs:
;     A  pen color (1-4)
;     HL video memory address
;     DE address to the null-terminated string 
; Outputs:
;	  None
;     AF, HL, DE, BC, IX and IY are modified.
cpc_Print:
	call    _rslib_setcolor
	ld      a,(_rslib_printing)
	cp      1   ; are we already printing?
	jp      z,_rslib_pushjob
	ld      (_rslib_memaddr),hl
	ex      de,hl
	call    _rslib_printstr
__cpcprint_popjobs:
	; lets remove any pending jobs
	ld      a,(_rslib_queueitems)
	or      a
	jp      z,_rslib_printingoff
	call    _rslib_popjob
	jr      __cpcprint_popjobs

; CPC_PRINTXY
; Prints a null-terminated string using a custom font and direct
; hardware access in the video memory indicated by X and Y coords.
; (ONLY MODE 1).
; Inputs:
;     A  pen color (1-4)
;     L  X coord.
;     H  Y coord.
;     DE address to the null-terminated string 
; Outputs:
;	  None
;     AF, HL, DE, BC, IX and IY are modified.
cpc_PrintXY:
	push    af
	push    de
	call    cpc_GetScrAddress
	pop     de
	pop     af
	jp      cpc_Print

read 'cpcrslib/video/getscraddress.asm'

; PRIVATE ROUTINE
; Set the PEN color stored in A
_rslib_setcolor:
	or      a 
	jr      z,__rslibset_color0
	cp      1
	jr      z,__rslibset_color1
	cp		2
	jr      z,__rslibset_color2
	ld      a,0b10001000
	jr      __rslib_applycolor
__rslibset_color0:
	xor     a
	jr      __rslib_applycolor
__rslibset_color1:
	ld      a,0b00001000
	jr      __rslib_applycolor
__rslibset_color2:
	ld      a,0b10000000
__rslib_applycolor:
	ld      (cc0_gpstd-1),a
	ld      (cc4_gpstd-1),a
	srl     a
	ld      (cc1_gpstd-1),a
	ld      (cc5_gpstd-1),a
	srl     a
	ld      (cc2_gpstd-1),a
	ld      (cc6_gpstd-1),a
	srl     a
	ld      (cc3_gpstd-1),a
	ld      (cc7_gpstd-1),a
	ret	

; PRIVATE ROUTINE
; Adds a printing job to the queue
_rslib_pushjob:
	di
	ld      ix,(_rslib_queuepos)
	ld      (ix+0),l
	ld      (ix+1),h
	ld      (ix+2),e
	ld      (ix+3),d
	inc     ix
	inc     ix
	inc     ix
	inc     ix
	ld      (_rslib_queuepos),ix
	ld      hl,_rslib_queueitems
	inc     (hl)
	ei
	ret

; PRIVATE ROUTINE
; Removes a printing job from the queue
_rslib_popjob:
	di
	ld      ix,(_rslib_queuepos)
	ld      l,(ix+0)
	ld      h,(ix+1)
	ld      e,(ix+2)
	ld      d,(ix+3)
	dec     ix
	dec     ix
	dec     ix
	dec     ix
	ld      (_rslib_queuepos),ix
	ld      hl,_rslib_queueitems
	dec     (hl)
	ei
	ret

; AUXILIAR ROUTINE
; Set the printing flag to 0 (False)
_rslib_printingoff:
	xor     a
	ld      (_rslib_printing),a
	ret

; AUXILIAR ROUTINE
; Prints the string
_rslib_printstr:
	ld      a,1
	ld      (_rslib_printing),a
	ld      a,(cpc_charfont_first)
	ld      b,a	   ; lets substract the first char in the table
	ld      a,(hl) ; to find the character index in the
	or      a      ; 
	ret     z      ;
	sub     b      ;
	ld      bc,cpc_charfont	; chars table
	push    hl
	ld      l,a		
	ld      h,0
	add     hl,hl
	add     hl,hl
	add     hl,hl
	add     hl,bc
	call 	_rslib_decodech
	ld      hl,(_rslib_memaddr)
	ld      de,_rslib_charshape
	call    _rslib_drawch
	ld      hl,(_rslib_memaddr)
	inc     hl
	inc     hl
	ld      (_rslib_memaddr),hl
	pop     hl
	inc     hl
	jr      _rslib_printstr

_rslib_queueitems: dw 0
_rslib_queuepos:   dw _rslib_queue
_rslib_queue:	   defs 12
_rslib_printing:   db 0   ; Print flag
_rslib_memaddr:    dw 0   ; Address where to print a string

; PRIVATE ROUTINE
; Draws the char shape
_rslib_drawch:
	db      &FD
	ld      h,8	
	ld      b,7
	ld      c,b
__drawch_hight2_loop:
__drawch_width2_loop:		
	ex      de,hl
	ldi
	ldi
	db      &FD
	dec     h
	ret     z	
	ex      de,hl   	   
__drawch_newline:
	ld      c,&FE			
	add     hl,bc
	jr      nc,__drawch_hight2_loop 
	ld      bc,&C050
	add     hl,bc
	ld      b,7	
	jr      __drawch_hight2_loop	
		
; PRIVATE ROUTINE
; Decodes a single char saving in _rslib_charshape the bits
; conforming the char.
; HL contains the address to the char in the font table.
_rslib_decodech:
	ld      iy,_rslib_charshape
	ld      b,8
__printch_loop:
	push    bc
	xor     a
	ld      b,(hl)  ; get char line from the font table
	bit     7,b
	jr      z,cc0_gpstd
	or      0b10001000
cc0_gpstd:
	bit     6,b
	jr      z,cc1_gpstd
	or      0b01000100
cc1_gpstd:
	bit     5,b
	jr      z,cc2_gpstd
	or      0b00100010
cc2_gpstd:
	bit     4,b
	jp      z,cc3_gpstd
	or      0b00010001
cc3_gpstd:
	ld      (iy+0),a
	inc     iy
	xor     a
	bit     3,b
	jr      z,cc4_gpstd
	or      0b10001000
cc4_gpstd:
	bit     2,b
	jr      z,cc5_gpstd
	or      0b01000100
cc5_gpstd:
	bit     1,b
	jp      z,cc6_gpstd
	or      0b00100010
cc6_gpstd:
	bit     0,b
	jp      z,cc7_gpstd
	or      0b00010001
cc7_gpstd:
	ld      (iy+0),a
	inc     iy
	inc     hl
	pop     bc
	djnz    __printch_loop
	ret

_rslib_charshape: defs 16
