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

; CPC_TESTKEYBOARD
; Based on the basic routines designed by Kevin Thacker,
; Queries the keyboard for its state and returns the result
; in A.
; Inputs:
;     None
; Outputs:
;	  A  state of the keyboard (tells if any line of the keys matrix is active)
;     AF and BC are modified.
cpc_TestKeyboard:
	di
	ld      bc,&F40E
	out     (c),c
	ld      bc,&F6C0
	out     (c),c
	db      &ED,&71   ; OUT (C),0
	ld      bc,&F792
	out     (c),c
	dec     b
	out     (c),a
	ld      b,&F4
	in      a,(c)
	ld      bc,&F782
	out     (c),c
	dec     b
	db      &ED,&71   ; OUT (C),0
	cpl
	ei
	ret
