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

; The following information has been extracted from:
; https://cpctech.cpcwiki.de/docs/keyboard.html
; It is important to read the full text there to gain a more deep knowledge about
; the procedure to scan the Amstrad CPC keyboard. Specially, about some special
; effects like the KEYBOARD CRASH.

; Scanning the Keyboard and Joysticks

; The keyboard and joysticks are scanned using the AY-3-8912 PSG and the 8255 PPI.
; The keys on the keyboard, and the joystick directions and buttons, are arranged
; in an 10 by 8 matrix. Each element of the matrix is a switch and represents the
; state of a key or a joystick button.

; The matrix is read a column at a time, each column is read as a byte, and this
; holds the state of 8 switches. When the matrix is read, a switch will be "0" or "1".
;	If the switch is "0" then the key/joystick button corresponding to that bit is pressed,
;   If the switch is "1" then the key/joystick button is not pressed, 

; Joystick 0 occupies it's own space in the matrix and is accessed at line 9. Joystick 1
; shares line 6 with the keyboard. As a result, it is possible to simulate the state of
; joystick 1 by pressing the appropiate keys on the keyboard.

;The position of each key/joystick button in the matrix is shown in the table below:
;                        		Bit
; Line 	7		6		5		4		3		2		1		0
; &40 	F Dot 	ENTER 	F3 		F6 		F9 	 CURDOWN CURRIGHT  CURUP
; &41 	F0 		F2 		F1 		F5 		F8 		F7 	   COPY    CURLEFT
; &42 	CONTROL \ ` 	SHIFT 	F4 		] }   RETURN  	[ { 	CLR
; &43 	. > 	/ ? 	: * 	; + 	P 		@ ¦ 	- = 	^ £
; &44 	, < 	M 		K 		L 		I 		O 		9 ) 	0 _
; &45 	SPACE 	N 		J	 	H 		Y 		U 		7 ' 	8 (
; &46**	V 		B  		F  		G		T		R		5 %		6 &
; &47 	X 		C 		D 		S 		W 		E 		3 # 	4 $
; &48 	Z 	CAPSLOCK 	A 		TAB 	Q 		ESC 	2 " 	1 !
; &49 	DEL 	Jfire3 	Jfire2 	Jfire1 	Jright 	Jleft 	Jdown 	Jup 
;
; ** This line maps the Joy2 keys too:
; B (J2 fire3) F (Joy2 fire2) G (Joy2 fire1) T (Joy2 right) R (Joy2 left) 5 % (Joy2 down) 6 & (Joy2 up)

; Algorithm for reading the keyboard and joysticks

; The matrix is connected to PSG I/O port A, and PPI Port C. (PSG Port A is accessed through PSG
; register 14). Bits 3..0 of PPI Port C are used to define the matrix line to read. The data of
; the selected matrix line will be present at the inputs to PSG Port A.
; The PSG is accessed through PPI Port A and PPI Port C. PPI port A is a databus. PPI Port C bit 7
; and 6 are used to define the PSG access function:
; PSG access function selection:
; PPI Port C Bits 	PSG Function 						Notes
;	7 	6
;	0 	0 			Inactive	
;	0 	1 			Read from selected PSG register.	The data from the PSG register will be present at PPI port A.
;	1 	0 			Write to selected PSG register. 	The data at PPI port A defines the data to write to the PSG register.
;	1 	1 			Select PSG register.				The data at PPI port A defines the PSG register index.

; The following sequence is required to read one or more matrix lines:
;   1. Write 14 to PPI Port A, (This is the index of the I/O Port A register of the PSG)
;   2. Select PSG operation: write register index, by setting bit 7="1" and bit 6="1" of PPI port C.
;   3. Select PSG operation: inactive, by setting bit 7="0" and bit 6="0" of PPI Port C.
;   4. Set Port A of the PPI to input (use PPI Control register),
;   5. Write matrix line into bit 3-0 of PPI Port C.
;   6. Select PSG operation: read register data, by setting bit 7="0 and bit 6="1" of PPI Port C.
;   7. Read matrix data from PPI port A.
;   8. If more lines are to be read go to step 5,
;   9. Set Port A of the PPI to output (use PPI Control register),
;  10. Select PSG operation: inactive, by setting bit 7="0" and bit 6="0" of PPI Port C. 

; Used by the different keyboard routines to save values.
_cpcrslib_keyline: 	db 0
_cpcrslib_keybyte:	db 0
_cpcrslib_keymap:	defs 10

; TABLE OF USER DEFINED KEYS (ASSIGMENT TABLE)
; Initialized with some default values. FFFF if the assignment is empty.
; For each entry: LINE MATRIX VALUE + BYTE MATRIX VALUE
_cpcrslib_keys_table:
key_0_x: 	dw &4002
key_1_x: 	dw &4101
key_2_x: 	dw &4001
key_3_x: 	dw &4004
key_4_x:	dw &4002
key_5_x:  	dw &4101
key_6_x:  	dw &4001
key_7_x:  	dw &4004
key_8_x:  	dw &4801
key_9_x:  	dw &4802
key_10_x:  	dw &4702
key_11_x:  	dw &4204
key_12_x:  	dw &FFFF
key_13_x:  	dw &4204
key_14_x:  	dw &4001
key_15_x:  	dw &4004
