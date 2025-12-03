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

; EXAMPLE 010 - Sprites

.main:
    ld      a,1
    call    cpc_SetModeFW

    ld      de,string1
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    ld      de,string2
    ld      l,0     ; X
    ld      h,8*24  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key

    ld      hl,&C19B
    ld      de,_sprite
    ld      b,3   ; sprite width
    ld      c,16  ; sprite height
    call    cpc_PutSp

    ld      de,string3
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key

    ld      hl,&C19B
    ld      de,_buffer
    ld      b,3   ; area width
    ld      c,16  ; area height
    call    cpc_GetSp

    ld      de,string4
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key

    ld      hl,&C19F
    ld      de,_buffer
    ld      b,3   ; sprite width
    ld      c,16  ; sprite height
    call    cpc_PutSp
    call    wait_key

    ld      de,string5
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key

    ld      l,100 ; X
    ld      h,50  ; Y
    ld      de,_sprite
    ld      b,3   ; sprite width
    ld      c,16  ; sprite height
    call    cpc_PutSpXY_XOR

    ld      de,string6
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key

    ld      l,100 ; X
    ld      h,50  ; Y
    ld      de,_sprite
    ld      b,3   ; sprite width
    ld      c,16  ; sprite height
    call    cpc_PutSpXY_XOR

    ld      de,string7
    ld      l,0     ; X
    ld      h,8*23  ; Y
    call    cpc_DrawStrXY_M1
    call    wait_key
    call    0

wait_key:
    .wait_loop
    call    cpc_AnyKeyPressed
    xor     a
	or      l
	jr      z,wait_loop
    ret

; Not all characters are defined in font_color.asm
; for example, the space is defined in the place of the symbol ';'
string1: db "1;PUTS;A;SPRITE;IN;THE;SCREEN",0
string2: db "PRESS;ANY;KEY",0
string3: db "2;CAPTURES;A;SCREEN;AREA;;;;;",0
string4: db "3;PRINTS;CAPTURED;AREA;;;;;;;",0
string5: db "4;PUTS;A SPRITE;IN;XOR;MODE;;",0
string6: db "5;SPRITE;PRINTED;AGAIN;IN;XOR;MODE",0
string7: db ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",0
string8: db "THE;END;;;;;;",0

_sprite:
    db &00,&60,&00
    db &00,&F0,&00
    db &10,&D0,&C0
    db &10,&F0,&E0
    db &10,&F0,&E0
    db &22,&E4,&C0
    db &33,&66,&00
    db &33,&77,&00
    db &33,&77,&00
    db &33,&CC,&00
    db &11,&EE,&00
    db &00,&FF,&00
    db &1F,&33,&00
    db &0D,&03,&0E
    db &0E,&0B,&0D
    db &05,&09,&0A

_buffer: defs 3*16 

read 'cpcrslib/firmware/setmode.asm'
read 'cpcrslib/keyboard/anykeypressed.asm'
read 'cpcrslib/text/font_color.asm'
read 'cpcrslib/text/drawstr_m1.asm'

read 'cpcrslib/sprite/putsp.asm'
read 'cpcrslib/sprite/getsp.asm'
read 'cpcrslib/sprite/putspxor.asm'

; ORIGINAL EXAMPLE IN C
; #include "cpcrslib.h"
; 
; extern const char sprite[], buffer[];
; 
; void data(void){
; __asm
; _sprite:
; .db #0x00,#0x60,#0x00
; .db #0x00,#0xF0,#0x00
; .db #0x10,#0xD0,#0xC0
; .db #0x10,#0xF0,#0xE0
; .db #0x10,#0xF0,#0xE0
; .db #0x22,#0xE4,#0xC0
; .db #0x33,#0x66,#0x00
; .db #0x33,#0x77,#0x00
; .db #0x33,#0x77,#0x00
; .db #0x33,#0xCC,#0x00
; .db #0x11,#0xEE,#0x00
; .db #0x00,#0xFF,#0x00
; .db #0x1F,#0x33,#0x00
; .db #0x0D,#0x03,#0x0E
; .db #0x0E,#0x0B,#0x0D
; .db #0x05,#0x09,#0x0A
; 
; _buffer:
; .db #0,#0,#0,#0,#0,#0,#0,#0
; .db #0,#0,#0,#0,#0,#0,#0,#0
; .db #0,#0,#0,#0,#0,#0,#0,#0
; .db #0,#0,#0,#0,#0,#0,#0,#0
; .db #0,#0,#0,#0,#0,#0,#0,#0
; .db #0,#0,#0,#0,#0,#0,#0,#0
; __endasm;
; }
; 
; main(){
;   unsigned char buffer[16*3];
; 	cpc_SetModo(1); //rutina hardware, se restaura la situaci�n anterior al terminar la ejecuci�n del programa
; 	
;   cpc_PrintGphStrXYM1("1;PUTS;A;SPRITE;IN;THE;SCREEN",0,8*23);
;   cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
;   while (!cpc_AnyKeyPressed()){}
; 	cpc_PutSp(sprite,16,3,0xc19b);
; 	// Captura de la pantalla el area indicada y la guarda en memoria.
;   cpc_PrintGphStrXYM1("2;CAPTURES;A;SCREEN;AREA;;;;;",0,8*23);
;   cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
;   while (!cpc_AnyKeyPressed()){}
; 	cpc_GetSp(buffer,16,3,0xc19c);
;   cpc_PrintGphStrXYM1("3;PRINTS;CAPTURED;AREA",0,8*23);
;   cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
;   while (!cpc_AnyKeyPressed()){}
; 	// En este ejemplo, imprime en &c19f el area capturada .
; 	cpc_PutSp(buffer,16,3,0xc19f);
; 	// Imprime el Sprite en modo XOR en la coordenada (x,y)=(100,50)
;   cpc_PrintGphStrXYM1("4;PUTS;A SPRITE;IN;XOR;MODE",0,8*23);
;   cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
;   while (!cpc_AnyKeyPressed()){}
;   cpc_PutSpXOR(sprite,16,3,cpc_GetScrAddress(100,50));
;   cpc_PrintGphStrXYM1("5;SPRITE;PRINTED;AGAIN;IN;XOR;MODE",0,8*23);
;   cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
;   while (!cpc_AnyKeyPressed()){}
;   cpc_PutSpXOR(sprite,16,3,cpc_GetScrAddress(100,50));
; 
;   cpc_PrintGphStrXYM1(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",0,8*23);
;   cpc_PrintGphStrXYM1("THE;END;;;;;;",0,8*24);
;   while(!(cpc_AnyKeyPressed())){}
; }