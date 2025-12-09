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

; EXAMPLE 011 - Small Sprite Demo (Scroll)
org &4000

.main
    ; Set colors and video mode
    ld      a,0
    call    cpc_SetModeFW
    call    set_colors
    call    print_credits
    ; Disable firmware interruption callback routine
    call    cpc_DisableFirmware

    call    _draw_tilemap
    call    cpc_RenderTileMap
    call    cpc_ShowTileMap
__endless_mainloop:
    ;call    cpc_ResetTouchedTiles
    ;call    cpc_RestoreTileMap ; restore original background
    ;call    cpc_ShowTileMap
    jr __endless_mainloop

_inks: db 0,22,11,2,1,3,6,9,23,14,15,24,25,17,13,26
_font_color: db TXT0_PEN0,TXT0_PEN8,TXT0_PEN9,TXT0_PEN14

set_colors:
    ld      ix,_inks
    ld      b,16
    ld      a,&FF
    __setink_loop:
        push    bc
        ld      b,(ix+0)
        ld      c,b
        inc     a
        push    af
        call    cpc_SetInkFW
        pop     af
        inc     ix
        pop     bc
    djnz    __setink_loop
    ld      bc,0
    jp      cpc_SetBorderFW

string1: db "SMALL;SCROLL;SPRITE;DEMO",0
string2: db "SDCC;;;CPCRSLIB",0
string3: db "BY;ARTABURU;2015",0
string4: db "ESPSOFT<AMSTRAD<ES",0

print_credits:
    ld      hl,_font_color
    call    cpc_SetTextColors_M0
    ld      de,string1
    ld      l,7*2+3 ; X
    ld      h,20*8  ; Y
    call    cpc_DrawStrXY_M0
    ld      de,string2
    ld      l,12*2+1; X
    ld      h,21*8  ; Y
    call    cpc_DrawStrXY_M0
    ld      de,string3
    ld      l,12*2  ; X
    ld      h,22*8  ; Y
    call    cpc_DrawStrXY_M0
    ld      de,string4
    ld      l,12*2-2; X
    ld      h,24*8  ; Y
    call    cpc_DrawStrXY_M0
    ret

_draw_bloque:
	push    ix
	ld      ix,0
	add     ix,sp
	ld	    l,(ix+6)
	ld      h,&00
	add     hl,hl
	add     hl,hl
	ex      de,hl
	ld	    hl,_blocks
	add     hl,de
	ld      c,(hl)
    ld      a,(ix+4)
	add     a
	ld      h,a
	ld      a,(ix+5)
	add     a
	ld      l,a
	push    hl       ; X Y
    push    de       ; blocks[]
	call    cpc_SetTile
	pop     de
    pop     hl
    inc     de
    ex      de,hl
    ld      c,(hl)
    ex      de,hl
    inc     h
    push    hl
    push    de
	call	cpc_SetTile
	pop     de
    pop     hl
    inc     de
    ex      de,hl
    ld      c,(hl)
    ex      de,hl
    dec     h
    inc     l
    push    hl
    push    de
    call	cpc_SetTile
	pop     de
    pop     hl
    inc     de
    ex      de,hl
    ld      c,(hl)
    ex      de,hl
    inc     h
	call	cpc_SetTile
	pop     ix
	ret

_draw_tilemap:
	ld      e,&00
__draw_for_y:
	ld      d,&00
__draw_for_x:
	ld      hl,_TILES_TOT_WIDTH + 0
	ld      h, (hl)
	push    de
	ld      l,&00
	ld      d,l
	ld      b,&08
__draw_test_item_loop:
	add     hl,hl
	jr      nc,__draw_test_item_next
	add     hl,de
__draw_test_item_next:
	djnz    __draw_test_item_loop
	pop     de
	ld      c,d
	ld      b,&00
	add     hl,bc
	ld      bc,_test_map2
	add     hl,bc
	ld      h,(hl)
	push    de
	push    hl
	inc     sp
	ld      a,e
	push    af
	inc     sp
	push    de
	inc     sp
	call    _draw_bloque
	pop     af
	inc     sp
	pop     de
	inc     d
	ld      a,d
	sub     &0E
	jr      c,__draw_for_x
	inc     e
	ld      a,e
	sub     &07
	jr      c,__draw_for_y
	ret

read 'tilemap_config/example5_def.asm'

read 'cpcrslib/firmware/setmode.asm'
read 'cpcrslib/firmware/setink.asm'
read 'cpcrslib/firmware/setborder.asm'
read 'cpcrslib/firmware/disablefw.asm'

read 'cpcrslib/text/font_color.asm'
read 'cpcrslib/text/drawstr_m0.asm'

read 'cpcrslib/tilemap/getdblbufferaddress.asm'
read 'cpcrslib/tilemap/settile.asm'
read 'cpcrslib/tilemap/rendertilemap.asm'
read 'cpcrslib/tilemap/resettouchedtiles.asm'
read 'cpcrslib/tilemap/putsptilemap.asm'
read 'cpcrslib/tilemap/restoretilemap.asm'
read 'cpcrslib/tilemap/drawmasksptilemap.asm'

_SCREEN_WIDTH:      dw &384
_TILES_TOT_WIDTH:   db &F0	; 240

struct_bullet:
    bullet_sp0 equ 0
	bullet_sp1 equ 2
	bullet_coord0 equ 4
	bullet_coord1 equ 6
	bullet_cx equ 8
    bullet_cy equ 9
    bullet_ox equ 10
    bullet_oy equ 11
    bullet_visible equ 12
    bullet_move equ 13
    bullet_type equ 14
    bullet_hide equ 15
    bullet_size equ 16

_bullets_array:  defs 6 * bullet_size
_ebullets_array: defs 6 * bullet_size

_player:
    ship_sp0: dw _spplayer
	ship_sp1: dw _spplayer
    ship_coord0: dw 0
    ship_coord1: dw 0
    ship_cx: db 12
    ship_cy: db 87
    ship_ox: db 12
    ship_oy: db 87
    ship_visible: db 3
    ship_move: db 0
    ship_vx: db 0         ; virtual X
    ship_pos: db 0
    ship_mode: db 0
    ship_hide: db 0
    ship_type: db 0
    ship_frame: db 0
    ship_num: db 0
    ship_dir: db 0
    ship_life: db 0

_enemy1:
    sprite0_sp0: dw _spship
	sprite0_sp1: dw _spship
    sprite0_coord0: dw 0
    sprite0_coord1: dw 0
    sprite0_cx: db 20
    sprite0_cy: db 40
    sprite0_ox: db 20
    sprite0_oy: db 40
    sprite0_visible: db 0
    sprite0_move: db 0
    sprite0_vx: db 20       ; virtual X
    sprite0_pos: db 0
    sprite0_mode: db 0
    sprite0_hide: db 0
    sprite0_type: db 3
    sprite0_frame: db 0
    sprite0_num: db 1       ; num=0 mosca, num=1 raton
    sprite0_dir: db 0
    sprite0_life: db 0

_enemy2:
    sprite1_sp0: dw _spship
	sprite1_sp1: dw _spship
    sprite1_coord0: dw 0
    sprite1_coord1: dw 0
    sprite1_cx: db 20
    sprite1_cy: db 45
    sprite1_ox: db 20
    sprite1_oy: db 45
    sprite1_visible: db 0
    sprite1_move: db 0
    sprite1_vx: db 120         ; virtual X
    sprite1_pos: db 0
    sprite1_mode: db 0
    sprite1_hide: db 0
    sprite1_type: db 3
    sprite1_frame: db 0
    sprite1_num: db 1
    sprite1_dir: db 0
    sprite1_life: db 0

_test_map2:
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,15,19,18,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,6,6,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11,11,11,14,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11,11,11,16,19,19,19,17,11,11,16,19,17,11,11
db 16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
db 11,11,11,11,11,11,11,11,11,11,6,6,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11,11,11,11,11
db 11,11,11,11,11,11,11,15,19,18,11,11,16,19,17,11,11,11,11,11,11,11,11,14,11,11,11,11,11,11,11,11,11,14,11,11
db 11,11,14,11,11,14,11,11,14,11,11,14,11,11,11,11,11,14,11,11,11,11,11,11,10,7,10,7,8,8,7,8,8,10,7,7,8,7,7,10
db 10,9,7,10,8,7,9,8,7,10,9,7,10,7,10,9,9,8,7,7,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11
db 11,11,15,19,19,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19
db 18,11,11,11,11,11,10,10,7,9,9,7,7,7,9,7,9,10,10,8,10,9,8,9,8,9,10,7,7,10,7,10,10,10,8,10,9,8,9,8,9,10,7,7,10
db 7,10,10,10,8,10,9,8,9,8,9,10,7,7,10,6,6,11,11,16,19,17,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11,11,11
db 11,11,11,11,11,11,11,11,16,19,19,28,17,11,15,19,18,11,11,11,11,11,11,11,16,19,17,11,11,11,11,11,11,11,16,19
db 17,11,11,16,19,17,16,19,17,16,19,17,16,19,17,11,11,11,16,19,17,11,11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,8,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,16
db 19,19,19,19,28,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,28,17
db 11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
db 3,3,3,3,3,3,6,6,11,11,15,19,18,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,11,11,11,11,11,11,11,11,11
db 15,19,19,19,18,16,19,19,19,17,11,11,11,11,11,11,15,19,18,11,11,11,11,11,11,11,15,19,18,11,11,15,19,18,15,19
db 18,15,19,18,15,19,18,11,11,11,15,19,18,11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
db 3,3,3,3,3,3,3,3,3,8,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,20,11,11,11,15,19,19,19,19,19,18,15,19,19
db 19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,11,11,10,3,3,3,3,3,3,3,3,3,3
db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,6,6,10,9,7,20,7,8,9
db 10,9,9,7,9,10,7,10,10,9,7,20,7,8,9,10,9,9,7,9,10,7,10,10,9,7,20,7,8,9,10,20,9,7,9,10,7,10,10,9,7,20,7,8,9,10
db 9,9,7,9,10,20,10,10,9,7,20,7,8,20,10,9,20,7,9,20,7,10,10,9,7,20,7,8,9,10,3,3,3,3,3,3,3,3,3,3,5,6,3,3,3,3,3,3,3
db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,8,8,8,9,7,8,10,10,8,7,8,7,8,8,10,8,20,8,9,7,8,10,20,20,20,8,7,8,8,20
db 8,8,8,9,20,8,10,10,8,20,8,7,8,8,20,8,8,8,9,20,8,10,10,8,20,8,7,8,7,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,6,6,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,2,21
db 2,2,2,2,2,2,2,2,4,4,4,2,2,2,21,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,21,2,2,21,2,2,21,2
db 2,21,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
db 2,2,2,2,2,2,2,2,2,2,2,4,4,21,2,4,4,2,2,21,21,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,4,4,2,21,2,2,2,2
db 21,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2
db 2,2,2,2,2,2,6,6,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,4,4,4,2,2,2,21,2,2,2,2,21,2,2,2,2,2,2
db 2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,21,2,2,21,2,2,21,2,2,21,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,21,2,4,4,2,2,21,21,21,2,2,2
db 2,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,4,4,2,21,2,2,2,2,21,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,6

_blocks:
db 1,40,3,40
db 1,40,3,13
db 40,40,13,13
db 40,40,40,40
db 5,6,13,13
db 40,40,5,6
db 0,1,2,3
db 41,41,40,40
db 42,41,40,40
db 42,42,40,40
db 41,42,40,40
db 43,43,43,43
db 32,33,32,33
db 12,12,40,40
db 45,44,47,46
db 45,48,47,48
db 43,45,43,47
db 44,43,46,43
db 48,44,48,46
db 48,48,48,48
db 49,49,49,49
db 49,49,13,13
db 50,51,53,52
db 50,51,53,52
db 50,51,53,52
db 50,51,53,52
db 50,51,53,52
db 50,51,53,52
db 50,51,53,52

_spship:
db 6,19
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0x25,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x10,0x00,0x4B,0x00,0x8D,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x10,0x00,0x4B,0x00,0xCC,0x55,0x0A
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0x0F,0x00,0x0F,0x55,0x0A
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0xAA,0x05,0xFF,0x00,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0x25,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0x55,0x20,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x10,0xAA,0x05,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x10,0x00,0x0F,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0x55,0x20,0x00,0x0F,0xFF,0x00,0xAA,0x14
db 0xFF,0x00,0xAA,0x14,0x00,0x30,0x00,0x3C,0x00,0x1C,0x00,0x1C
db 0xFF,0x00,0xFF,0x00,0xAA,0x10,0xAA,0x05,0xAA,0x10,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x05,0x00,0x25,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0x00,0x0F,0x00,0x0F,0x55,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x0F,0x00,0x0F,0x00,0x0F,0x00,0x0F,0x55,0x0A
db 0xAA,0x05,0x00,0x0F,0x00,0x0F,0x00,0x0F,0x00,0x0F,0x00,0x87
db 0xAA,0x10,0x00,0x25,0x00,0x0F,0x00,0x0F,0x00,0x4B,0x00,0x8D
db 0xFF,0x00,0xAA,0x10,0x00,0x30,0x00,0x0F,0x00,0x0F,0x55,0x0A
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0x30,0x55,0x20,0xFF,0x00

_spplayer
db 5,17
db 0xFF,0x00,0x00,0xF0,0x00,0xB4,0xFF,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0xF0,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0x00,0xA5,0x00,0x05,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0A,0x00,0x00,0x55,0xAA
db 0xAA,0x00,0x00,0x0A,0x00,0x0A,0x00,0x3F,0x55,0x2A
db 0xAA,0x00,0x00,0x0F,0x00,0x0F,0x00,0x00,0xFF,0x00
db 0xAA,0x00,0x00,0x0F,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x00,0x00,0xCC,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x88,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x44,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x44,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x50,0x00,0x50,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x50,0x00,0x50,0x55,0x00,0xFF,0x00

_spplayer0:
db 5,17
db 0xFF,0x00,0xAA,0x50,0x00,0xB4,0x55,0xA0,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0xF0,0xFF,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0x05,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xAA,0x00,0x00,0x05,0x00,0x0A,0x55,0x00,0x55,0xAA
db 0xAA,0x00,0x00,0x0A,0x00,0x0A,0x00,0x15,0x55,0x2A
db 0xAA,0x00,0x00,0x0F,0x00,0x0F,0x00,0x00,0xFF,0x00
db 0xAA,0x00,0x00,0x0F,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x00,0x00,0xCC,0x00,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x88,0x55,0x00,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x44,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x44,0x00,0xD8,0x55,0xA0
db 0xAA,0x50,0x00,0xA0,0xAA,0x00,0x00,0xF0,0x55,0xA0
db 0xAA,0x00,0x00,0xF0,0xFF,0x00,0x00,0x00,0xFF,0x00

_spplayeri
db 5,17
db 0xFF,0x00,0xFF,0x00,0x00,0x78,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0xF0,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x0A,0x00,0x5A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xAA,0x55,0x00,0x00,0x00,0x05,0x00,0x0A,0xFF,0x00
db 0xAA,0x15,0x00,0x3F,0x00,0x05,0x00,0x05,0x55,0x00
db 0xFF,0x00,0x00,0x00,0x00,0x0F,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xCC,0x00,0x00,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x44,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xA0,0x00,0xA0,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xA0,0x00,0xA0,0xFF,0x00

_spplayeri0:
db 5,17
db 0xFF,0x00,0xAA,0x50,0x00,0x78,0x55,0xA0,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0x00,0xF0,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x0A,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xAA,0x55,0xAA,0x00,0x00,0x05,0x00,0x0A,0x55,0x00
db 0xAA,0x15,0x00,0x2A,0x00,0x05,0x00,0x05,0x55,0x00
db 0xFF,0x00,0x00,0x00,0x00,0x0F,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0x00,0x00,0x00,0xCC,0x00,0x00,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x44,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0x00,0x44,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xAA,0x50,0x00,0xE4,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xAA,0x50,0x00,0xF0,0x55,0x00,0x00,0x50,0x55,0xA0
db 0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0xF0,0x55,0x00

_spplayers0:
db 5,17
db 0xFF,0x00,0xFF,0x00,0x00,0x78,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0xF0,0x00,0xF0,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x0A,0x00,0x5A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0A,0xFF,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x0F,0x00,0x0A,0xFF,0x00
db 0xAA,0x55,0x00,0x00,0x00,0x05,0x00,0x0A,0xFF,0x00
db 0xAA,0x15,0x00,0x3F,0x00,0x05,0x00,0x05,0x55,0x00
db 0xFF,0x00,0x00,0x00,0x00,0x0F,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0x00,0x05,0x00,0x00,0x00,0x0F,0x55,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xCC,0x00,0x00,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x44,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0x88,0x00,0x88,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xA0,0x00,0xA0,0xFF,0x00
db 0xFF,0x00,0xAA,0x00,0x00,0xA0,0x00,0xA0,0xFF,0x00

_spplayers1:
db 5,17
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xAA,0x04,0x00,0x0C,0xFF,0x00,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0x00,0x49,0x00,0xC3,0x55,0x08,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0x00,0xC3,0x00,0xEB,0x00,0x86,0xFF,0x00
db 0xFF,0x00,0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0x86,0xFF,0x00
db 0xFF,0x00,0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0x86,0xAA,0x50
db 0xFF,0x00,0x00,0xA4,0x00,0xFF,0x00,0xFF,0x00,0xAE,0x00,0xF0
db 0xAA,0x50,0xAA,0x04,0x00,0xFF,0x00,0xFF,0x00,0xAE,0xAA,0x50
db 0xFF,0x00,0x00,0xA4,0x00,0xFF,0x00,0xFF,0x00,0xAE,0xAA,0x50
db 0xFF,0x00,0x55,0xA0,0x00,0x5D,0x00,0xFF,0x00,0x0C,0x55,0xA0
db 0xFF,0x00,0x00,0xA4,0x00,0x0C,0x00,0x0C,0x55,0x08,0x55,0xA0
db 0xFF,0x00,0x00,0xA4,0x00,0x49,0x00,0xC3,0x00,0x0C,0x55,0xA0
db 0xFF,0x00,0x00,0xF0,0x00,0xD7,0x00,0xFF,0x00,0xD2,0x55,0xA0
db 0xFF,0x00,0x00,0x58,0x00,0xD7,0x00,0xFF,0x00,0xD2,0xFF,0x00
db 0xAA,0x04,0x00,0x49,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0xFF,0x00,0xC3,0x55,0x08
db 0xAA,0x04,0x00,0xEB,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xEB,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xD7,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xAA,0x04,0x00,0xEB,0x00,0xFF,0x00,0xFF,0x00,0xEB,0x55,0x08
db 0xFF,0x00,0x00,0xFF,0x00,0xD7,0x00,0xFF,0x00,0xC3,0x55,0x08
db 0xAA,0x50,0x00,0xF0,0x00,0xFF,0x00,0xEB,0x00,0x86,0xFF,0x00
db 0xFF,0x00,0x00,0xF0,0x00,0xA4,0x00,0x0C,0x00,0x58,0xFF,0x00
db 0xFF,0x00,0xFF,0x00,0xFF,0x00,0xFF,0x00,0x00,0xF0,0x55,0xA0

; ORIGINAL EXAMPLE IN C
; #include "cpcrslib.h"
; #include "datos.h"
; #include "estructuras.h"
; #include "scroll_engine.h"
; 
; const int ANCHO_PANTALLA_SC = 900;
; extern const unsigned char sp_1[];	//masked sprite data
; extern const unsigned char sp_2[];	//masked sprite data
; extern const unsigned char tintas[];	//inks
; extern unsigned char buffer[];	//inks
; 
; const unsigned char TILES_ANCHO_TOT = 240;
; 
; int pointerH=0;
; 
; // Para el control del scroll:
; unsigned char sc;
; unsigned char d;		// para ver si el sprite controlado por el usuario sigue la misma direcci�n o ha habido cambio
; unsigned char e, f;		// para controlar si el scroll cambia de direcci�n
; unsigned char vs1, vs2; // Controlan si habr� scroll total o medio
; 
; unsigned int col,colMax;		// Columna izquierda actual del scroll
; 
; void *p_nave;
; void *p_sprite[10];
; void *p_disparo[10];
; 
; unsigned char pilaEnemigos[60]; //[4*MAX_PILA_ENEMIGOS];
; unsigned char nPila;
; 
; void *p_sprites[7];
; 
; void initPointers() {
;     p_sprites[0] = &sprite00;
;     p_sprites[1] = &sprite01;
;     p_sprites[2] = &sprite02;
; }
; 
; void set_colours(void) {
;     unsigned char i;
;     for (i=0; i<17; i++)
;         cpc_SetColour(i,paleta[i]);
; }
;  
; void draw_bloque(unsigned char x, unsigned char y, unsigned char b) {
;     unsigned char tx, ty;
;     int tb;
;     tx = 2*x;
;     ty = 2*y;
;     tb = b*4;
; 
;     cpc_SetTile(tx,ty,bloques[tb]);
;     cpc_SetTile(tx+1,ty,bloques[tb+1]);
;     cpc_SetTile(tx,ty+1,bloques[tb+2]);
;     cpc_SetTile(tx+1,ty+1,bloques[tb+3]);
; }
; 
; void draw_tilemap(void) {
;     unsigned char x,y;
;     unsigned char t;
;     int tt;
;     for(y=0; y<7; y++) {
;         for(x=0; x<14; x++) {
;             tt=TILES_ANCHO_TOT*y+x;
;             t=test_map2[tt];
;             draw_bloque(x,y,t);
;         }
;     }
; }
; 
; void print_credits(void) {
;     cpc_PrintGphStrXY("SMALL;SCROLL;SPRITE;DEMO",7*2+2,20*8);
;     cpc_PrintGphStrXY("SDCC;;;CPCRSLIB",12*2+1,21*8);
;     cpc_PrintGphStrXY("BY;ARTABURU;2015",12*2+1-1,22*8);
;     cpc_PrintGphStrXY("ESPSOFT<AMSTRAD<ES",12*2+1-3,24*8);
; }
; 
; void actualizaPantalla(void) {
;     unsigned char i,o;
; 	cpc_ResetTouchedTiles();
;     switch (sc) {
;     case 0:		
; 		// NO SCROLL THIS TIME
;         cpc_PutSpTileMap(p_nave);
;         if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
;         if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
;         cpc_UpdScr();	// restaura los tiles actualizados
;         break;
;     case 1:
;         // SCROLL TILE MAP 1: 	PSEUDO SCROLL --> SCREEN START POSITION -1
;         cpc_ScrollLeft00();		
;         // SPRITE PRINTING:      
;         cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
;         if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
;         if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
;         cpc_UpdScr();	// restaura los tiles actualizados
;         // SCROLL CONTROL PARAMETERS:
;         vs1=1;
;         e=1;
;         f=0;
;         break;
;     case 2:
;         // SCROLL TILE MAP 1: 	PSEUDO SCROLL --> SCREEN START POSITION +1
;         cpc_ScrollRight00();
;         // SPRITE PRINTING:     
;         cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
;         if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
;         if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
;         cpc_UpdScr();	// restaura los tiles actualizados
;         // SCROLL CONTROL PARAMETERS:
;         vs1=2;
;         f=1;
;         e=0;
;         break;
;     case 3:		
;         // si ha habido scroll hacia la izquierda
; 		// 1. CLEAR ALL THE SPRITES IN THE SCREEN      
; 		if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
;         if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
; 		cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
;         cpc_UpdScr();
; 		// 2. UPDATE COORDINATES OF THE SPRITES IN THE SCREEN
; 		if (sprite00.visible==1) {
;             sprite00.cx-=2;
;             sprite00.ox-=2;
;         }
;         if (sprite01.visible==1) {
;             sprite01.cx-=2;
;             sprite01.ox-=2;
;         }
;         // SCROLL TILE MAP AND SCREEN START POSITION:
;         cpc_ScrollLeft01(); // scroll area tiles
;         // SPRITE UPDATING:
;         nave.cx-=2;
;         nave.ox-=2;
;         // SPRITE PRINTING:     
;         drawColumnD();		// actualiza area tiles nueva columna
;         cpc_PutMaskSpTileMap2b(p_nave);// Ahora se dibuja el sprite
;         // SCROLL CONTROL PARAMETERS:
;         vs1=3;
;         e=0;
;         col+=2;
;         if (colMax<col) colMax=col;
;         break;
;     case 4:
;         // si ha habido scroll hacia la izquierda
;         // SCROLL TILE MAP AND SCREEN START POSITION:       
; 		if (sprite00.visible==1 || sprite00.visible==2) cpc_PutSpTileMap(p_sprites[0]);
;         if (sprite01.visible==1 || sprite01.visible==2) cpc_PutSpTileMap(p_sprites[1]);
; 		cpc_PutSpTileMap(p_nave); // Para actualizar los tiles q toca el sprite
;         cpc_UpdScr();
;         if (sprite00.visible==1) {
;             sprite00.cx+=2;
;             sprite00.ox+=2;
;         }
;         if (sprite01.visible==1) {
;             sprite01.cx+=2;
;             sprite01.ox+=2;
;         }
;         cpc_ScrollRight01();	// scroll area tiles
;         // SPRITE UPDATING:
;         nave.cx+=2;
;         nave.ox+=2;
;         drawColumnI();			// actualiza area tiles nueva columna
;         // SCROLL CONTROL PARAMETERS:
;         vs1=4;
;         f=0;
;         col-=2;
;         break;
;     }
; 
;     cpc_PutMaskSpTileMap2b(p_nave);// Ahora se dibuja el sprite
;     if (sprite00.visible==1)cpc_PutMaskSpTileMap2b(p_sprites[0]);
;     if (sprite01.visible==1)cpc_PutMaskSpTileMap2b(p_sprites[1]);
;     cpc_ShowTileMap2();
; 	
;     if (sprite00.visible==2) {
;         sprite00.visible=3;
;     }
;     if (sprite01.visible==2) {
;         sprite01.visible=3;
;     }
; }
; 
; // viaible
; // 0: no se restaura ni se dibuja el sprite
; // 1: se dibuja y se restaura el sprite
; // 2: se restaura pero no se dibuja. El siguiente paso es visible = 3
; // 3: no se restaura ni se dibuja el sprite.
; 
; void act_visible(void) {  // dependiendo del scroll y de la posici�n del sprite, se activa o desactiva
;     char vpointerH;
; 
;     sprite00.cx=sprite00.vx-2*pointerH;
;     sprite01.cx=sprite01.vx-2*pointerH;
;     switch (sc) {
;         case 3:
;             if (sprite00.cx>2 && sprite00.cx<50) sprite00.visible = 1; else {
;                 if (sprite00.visible==1) {
;                     sprite00.visible = 2;
;                 }
;             }
;             if (sprite01.cx>2 && sprite01.cx<50) sprite01.visible = 1; else {
;                 if (sprite01.visible==1) {
;                     sprite01.visible = 2;
;                 }
;             }
;             break;
;         case 4:
;             if (sprite00.cx>0 && sprite00.cx<48) sprite00.visible = 1; else {
;                 if (sprite00.visible==1) {
;                     sprite00.visible = 2;
;                 }
;             }
;             if (sprite01.cx>2 && sprite01.cx<48) sprite01.visible = 1; else {
;                 if (sprite01.visible==1) {
;                     sprite01.visible = 2;
;                 }
;             }
;             break;
;         default:
;             if (sprite00.cx>0 && sprite00.cx<50) sprite00.visible = 1; else {
;                 if (sprite00.visible==1) {
;                     sprite00.visible = 2;
;                 }
;             }
;             if (sprite01.cx>0 && sprite01.cx<50) sprite01.visible = 1; else {
;                 if (sprite01.visible==1) {
;                     sprite01.visible = 2;
;                 }
;             }
;             break;
;     }
; }
; 
; main() {
;     unsigned char a;
;     unsigned char i,j,z,tt,rt,o;
;     unsigned char tmp2 = 0;
;     unsigned char tmp = 0;
;     unsigned char gravedad = 1;
;     unsigned char psalto = 0;
;     unsigned char suelo=0;
;     unsigned char enEscalera=0;
; 
;     cpc_DisableFirmware();
; 
;     cpc_SetMode(0);
;     initPointers();
; 	
;     cpc_SetInkGphStr(0,0);
;     cpc_SetInkGphStr(1,2);
;     cpc_SetInkGphStr(2,8);
;     cpc_SetInkGphStr(3,42);
; 	
;     d=0;
;     vs1=0;
;     vs2=0;
;     e=0;
;     f=0;
;     rt=0;
;     col=0;
;     colMax=0;
;     p_nave=&nave;
;     p_sprites[0] = &sprite00;
;     p_sprites[1] = &sprite01;
;     //Drawing the tile map
;     draw_tilemap();
;     print_credits();
; 	
;     cpc_ShowTileMap();		//Show entire tile map in the screen
;     cpc_ShowTileMap2();
;     set_colours();
; 
;     // Definiendo los protas del juego
;     nave.sp1=prota;
;     nave.sp0=prota;
;     nave.ox=12;
;     nave.oy=87;
;     nave.cx=12;
;     nave.cy=87;
;     nave.visible=3;
;     nave.move=0;
;     nave.posicion=0;
;     nave.modo=0;
; 
;     sprite00.sp1=spnave;
;     sprite00.sp0=spnave;
;     sprite00.ox=20;
;     sprite00.oy=40;
;     sprite00.cx=20;
;     sprite00.cy=40;
; 
;     sprite00.move=0;
;     sprite00.posicion=0;
;     sprite00.visible=0;
;     sprite00.vx=20;
;     sprite00.tipo=3;
;     sprite00.frame=0;
;     sprite00.num=1; // num=0 mosca, num=1 raton
;     sprite00.dir=0;
; 
;     sprite01.sp1=spnave;
;     sprite01.sp0=spnave;
;     sprite01.ox=20;
;     sprite01.oy=45;
;     sprite01.cx=20;
;     sprite01.cy=45;
; 
;     sprite01.move=0;
;     sprite01.posicion=0;
;     sprite01.visible=0;
;     sprite01.vx=120;
;     sprite01.tipo=3;
;     sprite01.frame=0;
;     sprite01.num=1; // num=0 mosca, num=1 rat�n
;     sprite01.dir=0;
; 
;     while(1) {
;         //Default number keys for moving one of the sprites:
;         // 0: cursor right
;         // 1: cursor left
;         sc=0;
;         if (cpc_TestKey(0)==1 && nave.cx<=40) {   // DERECHA
;             nave.cx++;
;             nave.move =0;
; 
;             if (rt==1) {
;                 nave.sp0 = prota;
;             }
;             else {
;                 nave.sp0 = prota0;
;             }
;             rt = !rt;
;             if (col<ANCHO_PANTALLA_SC) {
;                 if (nave.cx>=(40+e)) {  // se comprueba para ver si hay que hacer scroll al cambiar la direccion
;                     vs2=1;
;                     sc=1;   // SCROLL (<-)
;                 }
;             }
;         }
;         if (cpc_TestKey(1)==1 && nave.cx>0) {  // IZQUIERDA
;             nave.cx--;
;             nave.move =1;
;             if (rt==1) {
;                 nave.sp0 = protai;
;             }
;             else {
;                 nave.sp0 = protai0;
;             }
;             rt = !rt;
;             if (col>4) {
;                 if (nave.cx<=(10-f)) {  // se comprueba para ver si hay que hacer scroll al cambiar la direccion
;                     vs2=2;
;                     sc=1;	// SCROLL (->)
;                 }
;             }
;         }
; 
;         if (sc!=0) {	// Tipo de scroll que se realizar� (medio=solo se cambia el punto de lectura de pantalla o total=cambio de coordenadas)
;             if (vs1==1 && vs2==1) sc=3;  // scroll
;             if (vs1==1 && vs2==2) sc=2;  // 1/2 scroll
; 
;             if (vs1==2 && vs2==2) sc=4;  // scroll
;             if (vs1==2 && vs2==1) sc=1;  // 1/2 scroll
; 
;             if (vs1==3 && vs2==2) sc=4;  // scroll
;             if (vs1==3 && vs2==1) sc=1;  // 1/2 scroll
; 
;             if (vs1==4 && vs2==1) sc=3;  // scroll
;             if (vs1==4 && vs2==2) sc=2;  // 1/2 scroll
;         }
;         // The other sprites are automatically moved
;         if (sprite00.move==0) {   //0 = left, 1 = right
;             if (sprite00.vx>0) sprite00.vx--;
;             else sprite00.move=1;
;         } else {
;             if (sprite00.move==1) {   //0 = left, 1 = right
;                 if (sprite00.vx<90) sprite00.vx++;
;                 else sprite00.move=0;
;             }
;         }
;         if (sprite01.move==0) {  //0 = left, 1 = right
;             if (sprite01.vx>100) sprite01.vx--;
;             else sprite01.move=1;
;         } else {
;             if (sprite01.move==1) {   //0 = left, 1 = right
;                 if (sprite01.vx<220) sprite01.vx++;
;                 else sprite01.move=0;
;             }
;         }
;         act_visible();
;         actualizaPantalla();
;     }
; }
