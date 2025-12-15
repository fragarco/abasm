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
    ; ESC key is already assigned to entry 15 (&0F) by default
    ; but just for this example let's assign it to entry 5 too.
    ld      e,4             ; table entry index
    ld      bc,&4804        ; keyboard matrix line + byte
    call    cpc_AssignKey   ; assign ESC key

    ld      hl,string1
    call    cpc_PrintStrFW  ; Welcome to cpcrslib keyboard utilities.
    ld      hl,string2
    call    cpc_PrintStrFW  ; Press a key to redefine assignment #0

    ld      l,0
    call    cpc_RedefineKey
    ld      hl,string3
    call    cpc_PrintStrFW  ; Done!

    ld      hl,string4
    call    cpc_PrintStrFW  ; Now, press any key to continue
    .wait_key01
        call    cpc_AnyKeyPressed
        xor     a
		or      l
		jr      z,wait_key01

    ld      hl,string5
    call    cpc_PrintStrFW  ; Press a Key to redefine assignment #3    
    ld      l,3
    call    cpc_RedefineKey
    ld      hl,string3
    call    cpc_PrintStrFW  ; Done!

    ld      b,100           ; WAIT() loop
    wait_loop:
        halt
        djnz wait_loop:
    ld      a,1
    call    cpc_SetModeFW
    ld      bc,&0303
    call    cpc_SetBorderFW

    ld      hl,string6
    call    cpc_PrintStrFW  ; Now let's test the selected keys. Press ESC to EXIT

    ; Although this example uses cpc_TestKey calls, when several keys
    ; must be tested it is better to use cpc_ScanKeyboard and cpc_CheckKey
    test_keys_loop:
        test_key_entry0:
            ld      l,0
            call    cpc_TestKey
            xor     a
            or      l
            jr      z,test_key_entry3
            ld      hl,string7
            call    cpc_PrintStrFW  ; Key #0 pressed
        test_key_entry3:
            ld      l,3
            call    cpc_TestKey
            xor     a
            or      l
            jr      z,test_key_entry4
            ld      hl,string8
            call    cpc_PrintStrFW  ; Key #3 pressed
        test_key_entry4:
            ld      l,4
            call    cpc_TestKey
            xor     a
            or      l
            jr      z,test_keys_loop ; loop if not ESC key

    call 0

string1: db "Welcome to cpcrslib keyboard utilities.",0
string2: db "Press a key to redefine assignment #0",0
string3: db "Done!",0
string4: db "Now, press any key to continue",0
string5: db "Press a Key to redefine assignment #3",0
string6: db "Now let's test the selected keys. Press ESC to EXIT",0
string7: db "Key #0 pressed",0
string8: db "Key #3 pressed",0

read 'cpcrslib/firmware/setmode.asm'
read 'cpcrslib/firmware/setborder.asm'
read 'cpcrslib/firmware/print.asm'

read 'cpcrslib/keyboard/anykeypressed.asm'
read 'cpcrslib/keyboard/assignkey.asm'
read 'cpcrslib/keyboard/redefinekey.asm'
read 'cpcrslib/keyboard/testkey.asm'

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