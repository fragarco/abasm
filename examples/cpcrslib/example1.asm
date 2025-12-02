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

; EXAMPLE 001 - 8x8 Chars & Small Scroll

org &4000

.main:
	call    cpc_DisableFirmware
	call	cpc_ClearScr
	
	ld      a,1
	call    cpc_SetMode
	ld      hl,&0054
	call    cpc_SetColor
	ld      hl,&1054
	call    cpc_SetColor

	ld      a,1
	ld      de,string1
	ld      hl,&C050
	call    cpc_Print_M1

	ld      a,2
	ld      de,string2
	ld      hl,&C0A0
	call    cpc_Print_M1

	ld      a,3
	ld      de,string3
	ld      hl,&C0F0
	call    cpc_Print_M1

	ld      a,3
	ld      de,string4
	ld      l,8
	ld      h,70
	call    cpc_PrintXY_M1
	
	ld      a,2
	ld      de,string5
	ld      l,19
	ld      h,80
	call    cpc_PrintXY_M1
	
	ld      a,1
	ld      de,string6
	ld      l,2
	ld      h,160
	call    cpc_PrintXY_M1
	
	ld      a,1
	ld      de,string7
	ld      l,2
	ld      h,174
	call    cpc_PrintXY_M1

	.scroll_loop:
		ld      hl,&E000
		ld      e,40
		ld      d,79
		call    cpc_RRI
		ld      hl,&E4B0
		ld      e,32
		ld      d,79
		call    cpc_RRI

		ld      hl,&E5F0 + &50 + &50 + 79
		ld      e,12
		ld      d,79
		call    cpc_RLI

		call    cpc_AnyKeyPressed
		xor     a
		or      l
		jr      z,scroll_loop

	call    cpc_EnableFirmware
	call    0

string1: db "THIS IS A SMALL DEMO",0
string2: db "OF MODE 1 TEXT WITH",0
string3: db "8x8 CHARS WITHOUT FIRMWARE",0
string4: db "AND A SMALL SOFT SCROLL DEMO",0
string5: db "CPCRSLIB (C) 2015",0
string6: db "-- FONT BY ANJUEL  2009  --",0
string7: db "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0

read 'cpcrslib/firmware/enablefw.asm'
read 'cpcrslib/firmware/disablefw.asm'

read 'cpcrslib/video/clearscr.asm'
read 'cpcrslib/video/setmode.asm'
read 'cpcrslib/video/setcolor.asm'
read 'cpcrslib/video/rri.asm'
read 'cpcrslib/video/rli.asm'

read 'cpcrslib/text/font_nanako.asm'
read 'cpcrslib/text/print_m1.asm'

read 'cpcrslib/keyboard/anykeypressed.asm'

; ORIGINAL EXAMPLE IN C
; #include <cpcrslib.h>
; 
; char main (void) {
; 	unsigned char z=0;
; 
; 	cpc_DisableFirmware();		//Now, I don't gonna use any firmware routine so I modify interrupts jump to nothing
; 	cpc_ClrScr();				//fills scr with ink 0
; 	cpc_SetMode(1);				//hardware call to set mode 1
; 
;   cpc_SetColour(0,20);        //set background = black
;   cpc_SetColour(16,20);       //set border = black
; 
; 	cpc_PrintGphStrStd(1,"THIS IS A SMALL DEMO", 0xc050);	//parameters: pen, text, adress
; 	cpc_PrintGphStrStd(2,"OF MODE 1 TEXT WITH",0xc0a0);
; 	cpc_PrintGphStrStd(3,"8x8 CHARS WITHOUT FIRMWARE",0xc0f0);
; 	cpc_PrintGphStrStdXY(3,"AND A SMALL SOFT SCROLL DEMO",8,70);
; 	cpc_PrintGphStrStdXY(2,"CPCRSLIB (C) 2015",19,80);
; 	cpc_PrintGphStrStdXY(1, "-- FONT BY ANJUEL  2009  --",2,160);
; 	cpc_PrintGphStrStdXY(1,"ABCDEFGHIJKLMNOPQRSTUVWXYZ",2,174);
; 
; 	while (cpc_AnyKeyPressed()==0) {			//Small scrolling effect
; 	   z = !z;
; 	   if (z) {
; 	      cpc_RRI (0xe000, 40, 79);
; 	      cpc_RRI (0xe4b0, 32, 79);
; 	   }
; 	   cpc_RLI (0xe5f0+0x50+0x50+79, 12, 79);
; 	}
; 
; 	cpc_EnableFirmware();	//before exit, firmware jump is restored
; 	return 0;
; }


