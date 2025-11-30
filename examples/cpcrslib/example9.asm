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

; EXAMPLE 009 - Keyboard

.main:
    ld      a,1
    call    cpc_SetModeFW

    ld      hl,string1
    call    cpc_PrintStrFW
    ld      hl,string2
    call    cpc_PrintStrFW

.end_loop: jr end_loop

string1: db "Welcome to cpcrslib keyboard utilities.",0
string2: db "Press a key to redefine as #1",0

read 'cpcrslib/firmware/setmode.asm'
read 'cpcrslib/firmware/print.asm'


.wait:
    ld      b,100
    wait_loop:
        halt
        djnz wait_loop:

; ORIGINAL EXAMPLE IN C
; #include "cpcrslib.h"
; 
; void wait(void){
; 	__asm
;         _kkk:
;         ld b,#100
;         llll:
;         halt
;         djnz llll
; 	__endasm;
; }
; 
; main() {
; 	cpc_SetModo(1);
; 	
; 	cpc_AssignKey(4,0x4804);		// key "ESC"
; 	
; 	cpc_PrintStr("Welcome to cpcrslib keyboard utilities.");
; 	cpc_PrintStr("Press a Key to redefine as #1");
; 	cpc_RedefineKey(0);		//redefine key. There are 12 available keys (0..11)
; 	cpc_PrintStr("Done!");
; 
; 	cpc_PrintStr("Now, press any key to continue");
; 	while(!(cpc_AnyKeyPressed())){}
; 
; 	cpc_PrintStr("Well done! Let's do it again");
; 	cpc_PrintStr("Press any key to continue");
; 	while(!(cpc_AnyKeyPressed())){}
; 
; 	cpc_PrintStr("Press a Key to redefine as #3");
; 	cpc_RedefineKey(3);		//redefine key. There are 12 available keys (0..11)
; 	cpc_PrintStr("Done!");
; 
;     wait();
; 	cpc_SetModo(1);
; 	cpc_SetBorder(3);
; 
; 	cpc_PrintStr("Now let's test the selected keys. Press ESC to EXIT");
; 	cpc_PrintStr("Press a Key to test it..");
; 	while (!cpc_TestKey(4)) { // IF NOT ESC is pressed
; 		if (cpc_TestKey(0)) {	//test if the key has been pressed.
; 			cpc_PrintStr("OK Key #1");
; 		}
; 		if (cpc_TestKey(3)) {	//test if the key has been pressed.
; 			cpc_PrintStr("OK Key #2");
; 		}
; 		//else cpc_PrintStr(no);
; 	}
; 	return 0;
; }