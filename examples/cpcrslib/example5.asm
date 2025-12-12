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
    call    update_actor_positions
    call    update_actor_states
    call    update_screen   
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

; DE = Block X,Y  (0-13, 0-7)
; L  = Block index (0-28)
_draw_block:
    push    de      ; Store block X,Y parameters
	ld      h,&00
	add     hl,hl
	add     hl,hl   ; HL = block * 4
	ex      de,hl   ; DE = block * 4
	ld	    hl,_block_array
	add     hl,de   ; HL points to the block
	ld      c,(hl)  ; C = tile index
    pop     de      ; Pop block X,Y position
    push    hl      ; Store block starting position
    ld      a,d 
	add     a
	ld      h,a     ; H = X * 2 (tile X pos)
	ld      a,e
	add     a
	ld      l,a     ; L = Y * 2 (tile Y pos)
    push    hl      ; Store current tile position
	call    cpc_SetTile

    pop     hl
    pop     de
    inc     de      ; next tile index in the block
    ex      de,hl
    ld      c,(hl)  ; C = tile index
    ex      de,hl
    inc     h
    push    de      ; Store curent block tile address
    push    hl      ; Store current tile position
	call	cpc_SetTile

    pop     hl
	pop     de
    inc     de      ; next tile index in the block
    ex      de,hl
    ld      c,(hl)  ; C = tile index
    ex      de,hl
    dec     h
    inc     l
    push    de      ; Store curent block tile address
    push    hl      ; Store current tile position
    call	cpc_SetTile

    pop     hl
	pop     de
    inc     de      ; next tile index in the block
    ex      de,hl
    ld      c,(hl)  ; C = tile index
    ex      de,hl
    inc     h
	call	cpc_SetTile
	ret

; Goes through the first 14 blocks of each level map line (7)
; and draws the tilemap background with them. As every block
; is 2x2 tiles, the final background is 28x14 tiles which matches
; the T_WIDTH and T_HEIGHT set in example5_def.asm
_draw_tilemap:
	ld      e,&00  ; y index
__draw_for_y:
	ld      d,&00  ; x index
__draw_for_x:
    push    de     ; store FOR indexes (x,y)
	ld      hl,_level_block_width
	ld      h,(hl) ; 240
	ld      l,&00
	ld      d,l
	ld      b,&08
__draw_test_item_loop:
	add     hl,hl
	jr      nc,__draw_test_item_next
	add     hl,de
__draw_test_item_next:
	djnz    __draw_test_item_loop
	pop     de     ; pop FOR indexes
	ld      c,d    ; C = X
	ld      b,&00
	add     hl,bc
	ld      bc,_level_map
	add     hl,bc
	ld      l,(hl) ; L = Block number
    push    de     ; store FOR indexes (x,y)
	call    _draw_block
	pop     de     ; pop FOR indexes (x,y)
	inc     d
	ld      a,d
	sub     &0E
	jr      c,__draw_for_x
	inc     e
	ld      a,e
	sub     &07
	jr      c,__draw_for_y
	ret

check_rightscroll:
    ld      hl,(_scroll_col)  ; _scroll_col < _level_scroll_width ?
    ld      bc,(_level_scroll_width)
    xor     a
    sbc     hl,bc
    ret     nc
    ld      a,(_scroll_roff)   ; player.cx >= 40 + _scroll_roff ?
    add     40
    ld      b,a
    ld      a,(player_cx)
    sub     b
    ret     c
    ld      a,1
    ld      (_scroll_mode),a
    ld      (_scroll_vs2),a
    jp      update_scrollmode

check_leftscroll:
    ld      bc,(_scroll_col)   ; _scroll_col > 4 ?
    ld      hl,4
    xor     a
    sbc     hl,bc
    ret     nc
    ld      a,(player_cx)
    ld      b,a
    ld      a,(_scroll_loff)   ; player.cx <= 10 - _scroll_loff ?
    ld      c,a
    ld      a,10
    sub     c
    sub     b
    ret     c
    ld      a,1
    ld      (_scroll_mode),a   ; _scroll_mode = 1
    inc     a
    ld      (_scroll_vs2),a    ; _scroll_vs2  = 2
    jr      update_scrollmode

update_scrollmode:
    ; The scroll mode is adjusted depending on the values of _scroll_vs1 and
    ; _scroll_vs2 BUT only if _scroll_mode is already <> 0 and vs1 and vs2 <> 0
    ; _scroll_mode = 1   1/2 scroll
    ; _scroll_mode = 2   1/2 scroll
    ; _scroll_mode = 3   full scroll
    ; _scroll_mode = 4   full scroll
    ld      a,(_scroll_mode)
    or      a
    ret     z
    ld      a,(_scroll_vs2)
    or      a
    ret     z
    ld      b,a
    ld      a,(_scroll_vs1)
    or      a
    ret     z
    ld      c,a
    ; BC = vs2,vs1
    cp      1  ; vs1 == 1?
    jr      z,__vs1_1_or_4
    cp      2
    jr      z,__vs1_2_or_3
    cp      3
    jr      z,__vs1_2_or_3
    cp      4
    ret     nz
__vs1_1_or_4:
    ld      a,4
    sub     b  ; scroll = 2 if vs2 == 2 else scroll = 3
    ld      (_scroll_mode),a
    ret
__vs1_2_or_3:
    ld      a,b
    cp      1  ; vs2 == 1?
    jr      z,$+4
    sla     a  ; a = 4
    ld      (_scroll_mode),a
    ret

update_playerpos:
    ; by default, the key assignment table used by cpc_TestKey
    ; has the four first entries assigned to cursor keys
__test_cursor_right:
    xor     a
    ld      l,a
    call    cpc_TestKey
    ld      a,h
    or      l
    jr      z,__test_cursor_left
    ld      a,(player_cx)
    cp      41  ; only if cx <= 40
    jr      nc,__test_cursor_left
    inc     a
    ld      (player_cx),a       ; player.cx = player.cx + 1
    xor     a
    ld      (player_move),a     ; player.move = 0
    ld      a,(player_frame)    ; player.frame = !player.frame
    inc     a
    and     &01
    cp      0
    jr      nz,__test_right_f2  ; change sprite according to frame [0,1]
    ld      hl,_spplayerR0
    jr      $+5
    __test_right_f2
    ld      hl,_spplayerR1
    ld      (player_sp0),hl     ; landing place for $+5
    ld      (player_frame),a
    jp      check_rightscroll
__test_cursor_left:
    ld      l,1
    call    cpc_TestKey
    ld      a,h
    or      l
    jr      z,__test_cursor_end
    ld      a,(player_cx)
    cp      1   ; only if cx > 0
    jr      c,__test_cursor_end
    dec     a
    ld      (player_cx),a       ; player.cx = player.cx - 1
    xor     a                 
    inc     a
    ld      (player_move),a     ; player.move = 1
    ld      a,(player_frame)    ; player.frame = !player.frame
    inc     a              
    and     &01
    cp      0
    jr      nz,__test_left_f2   ; change sprite according to frame [0,1]
    ld      hl,_spplayerL0
    jr      $+5
    __test_left_f2
    ld      hl,_spplayerL1
    ld      (player_sp0),hl     ; landing place for $+5
    ld      (player_frame),a
    jp      check_leftscroll
__test_cursor_end:
    ret

update_actor_positions:
    xor     a
    ld      (_scroll_mode),a    ; reset scroll mode to no-scroll 
    call    update_playerpos
    ret

update_actor_states:
    ret

update_screen:
    call    cpc_ResetTouchedTiles
    ; Mark as dirty current sprite positions, so these tiles
    ; can be restored (deleting the sprite in the process)
    ld      a,(_scroll_mode)
    cp      1
    jr      nz,__update_scroll_no_1:
    ; PSEUDO SCROLL --> SCREEN START POSITION -1
    call    cpc_ScrollLeft00
    xor     a
    ld      (_scroll_loff),a
    inc     a
    ld      (_scroll_roff),a
    ld      (_scroll_vs1),a
    jr      __update_draw_screen
__update_scroll_no_1:
    cp      2
    jr      nz,__update_scroll_no_2:
    ; PSEUDO SCROLL --> SCREEN START POSITION +1
    call    cpc_ScrollRight00
    xor     a
    ld      (_scroll_roff),a
    inc     a
    ld      (_scroll_loff),a
    inc     a
    ld      (_scroll_vs1),a
    jr      __update_draw_screen
__update_scroll_no_2:
    cp      3
    jr      nz,__update_scroll_no_3:
__update_scroll_no_3:
    cp      4
    jr      nz,__update_draw_screen:
__update_draw_screen:
    ld      hl,_player
    call    cpc_PutSpTileMap
    call    cpc_RestoreTileMap ; restore original background
    ld      hl,_player
    call    cpc_DrawMaskSpTileMap
    call    cpc_ShowTileMap
    ret

read 'tilemap_config/example5_def.asm'

read 'cpcrslib/firmware/setmode.asm'
read 'cpcrslib/firmware/setink.asm'
read 'cpcrslib/firmware/setborder.asm'
read 'cpcrslib/firmware/disablefw.asm'

read 'cpcrslib/text/font_color.asm'
read 'cpcrslib/text/drawstr_m0.asm'

read 'cpcrslib/keyboard/testkey.asm'

read 'cpcrslib/tilemap/getdblbufferaddress.asm'
read 'cpcrslib/tilemap/settile.asm'
read 'cpcrslib/tilemap/rendertilemap.asm'
read 'cpcrslib/tilemap/resettouchedtiles.asm'
read 'cpcrslib/tilemap/putsptilemap.asm'
read 'cpcrslib/tilemap/restoretilemap.asm'
read 'cpcrslib/tilemap/drawmasksptilemap.asm'

read 'cpcrslib/tilemap/cpcscrollright.asm'
read 'cpcrslib/tilemap/cpcscrollleft.asm'

read 'cpcrslib/video/setcolor.asm' ; AAA

_player:
    player_sp0: dw _spplayerR0
	player_sp1: dw _spplayerR0
    player_coord0: dw 0
    player_coord1: dw 0
    player_cx: db 12
    player_cy: db 87
    player_ox: db 12
    player_oy: db 87
    player_visible: db 3
    player_move: db 0
    player_vx: db 0         ; virtual X
    player_pos: db 0
    player_mode: db 0
    player_hide: db 0
    player_type: db 0
    player_frame: db 0
    player_num: db 0
    player_dir: db 0
    player_life: db 0

_enemy1:
    enemy1_sp0: dw _spenemy
	enemy1_sp1: dw _spenemy
    enemy1_coord0: dw 0
    enemy1_coord1: dw 0
    enemy1_cx: db 20
    enemy1_cy: db 40
    enemy1_ox: db 20
    enemy1_oy: db 40
    enemy1_visible: db 0
    enemy1_move: db 0
    enemy1_vx: db 20       ; virtual X
    enemy1_pos: db 0
    enemy1_mode: db 0
    enemy1_hide: db 0
    enemy1_type: db 3
    enemy1_frame: db 0
    enemy1_num: db 1       ; num=0 mosca, num=1 raton
    enemy1_dir: db 0
    enemy1_life: db 0

_enemy2:
    enemy2_sp0: dw _spenemy
	enemy2_sp1: dw _spenemy
    enemy2_coord0: dw 0
    enemy2_coord1: dw 0
    enemy2_cx: db 20
    enemy2_cy: db 45
    enemy2_ox: db 20
    enemy2_oy: db 45
    enemy2_visible: db 0
    enemy2_move: db 0
    enemy2_vx: db 120         ; virtual X
    enemy2_pos: db 0
    enemy2_mode: db 0
    enemy2_hide: db 0
    enemy2_type: db 3
    enemy2_frame: db 0
    enemy2_num: db 1
    enemy2_dir: db 0
    enemy2_life: db 0

; Scroll control variables
; CAUTION: _scroll_mode is used initially to set if there is scroll (=1) or not (=0).
; After that, depending on vs1 and vs2 its value is changed to the propper scroll mode 1-4
_scroll_mode:   db 0 ; Defines current scroll state 0=off, 1-4 scroll type
_scroll_vs1:    db 0 ; vs1 and vs2 define if we should perform a total or half scroll
_scroll_vs2:    db 0 ; I couldn't figure out what vsX stands for so I had to keep
                     ; original names :(
_scroll_roff:   db 0 ; Modifies the point (column) when the right scroll starts
_scroll_loff:   db 0 ; Modifies the point (column) when the left scroll starts
_scroll_col:    dw 0 ; Current "scroll position" or column
_scroll_colmax: dw 0 ; 

; The level map is 240 blocks width and 8 blocks hight.
; Each byte has the block index.
; Each block defines an area of 2x2 tiles
; Each tile is 2x8 bytes (in mode 0, 4x8 pixeles).
_level_block_width:  db 240
_level_block_hight:  db 8
_level_scroll_width: dw 900 ; max "byte" aligned positions or "virtual columns"
_level_map:
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,6,6
db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11,11,11,16,19,19,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,16,19,17,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,6,6
db 11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,16,19,17,11,11,11,11,11,11,11,11,14,11,11,11,11,11,11,11,11,11,14,11,11,11,11,14,11,11,14,11,11,14,11,11,14,11,11,11,11,11,14,11,11,11,11,11,11,10,7,10,7,8,8,7,8,8,10,7,7,8,7,7,10,10,9,7,10,8,7,9,8,7,10,9,7,10,7,10,9,9,8,7,7,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11,11,11,15,19,19,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,15,19,18,11,11,11,11,11,10,10,7,9,9,7,7,7,9,7,9,10,10,8,10,9,8,9,8,9,10,7,7,10,7,10,10,10,8,10,9,8,9,8,9,10,7,7,10,7,10,10,10,8,10,9,8,9,8,9,10,7,7,10,6,6
db 11,11,16,19,17,11,11,11,11,11,11,11,11,11,11,11,11,16,19,17,11,11,11,11,11,11,11,11,11,11,11,16,19,19,28,17,11,15,19,18,11,11,11,11,11,11,11,16,19,17,11,11,11,11,11,11,11,16,19,17,11,11,16,19,17,16,19,17,16,19,17,16,19,17,11,11,11,16,19,17,11,11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,8,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,16,19,19,19,19,28,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,19,17,16,19,19,28,17,11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,6,6
db 11,11,15,19,18,11,11,11,11,11,11,11,11,11,11,11,11,15,19,18,11,11,11,11,11,11,11,11,11,11,11,15,19,19,19,18,16,19,19,19,17,11,11,11,11,11,11,15,19,18,11,11,11,11,11,11,11,15,19,18,11,11,15,19,18,15,19,18,15,19,18,15,19,18,11,11,11,15,19,18,11,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,8,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,20,11,11,11,15,19,19,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,15,19,19,19,18,11,11,10,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,6,6
db 10,9,7,20,7,8,9,10,9,9,7,9,10,7,10,10,9,7,20,7,8,9,10,9,9,7,9,10,7,10,10,9,7,20,7,8,9,10,20,9,7,9,10,7,10,10,9,7,20,7,8,9,10,9,9,7,9,10,20,10,10,9,7,20,7,8,20,10,9,20,7,9,20,7,10,10,9,7,20,7,8,9,10,3,3,3,3,3,3,3,3,3,3,5,6,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,8,8,8,9,7,8,10,10,8,7,8,7,8,8,10,8,20,8,9,7,8,10,20,20,20,8,7,8,8,20,8,8,8,9,20,8,10,10,8,20,8,7,8,8,20,8,8,8,9,20,8,10,10,8,20,8,7,8,7,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,6,6
db 2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,4,4,4,2,2,2,21,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,21,2,2,21,2,2,21,2,2,21,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,21,2,4,4,2,2,21,21,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,4,4,2,21,2,2,2,2,21,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,6
db 2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,4,4,4,2,2,2,21,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,21,2,2,2,2,21,2,2,21,2,2,21,2,2,21,2,2,2,2,2,21,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,21,2,4,4,2,2,21,21,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,2,2,2,21,2,4,4,2,21,2,2,2,2,21,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,6

; Each block (4 items) defines a region of 2x2 tiles
; our tilemap has 24x14 tiles
; so we can compose the screen with 14x7 blocks
_block_array:
db 01,40,03,40  ; block 0
db 01,40,03,13  ; block 1
db 40,40,13,13  ; block 2
db 40,40,40,40  ; block 3
db 05,06,13,13  ; block 4
db 40,40,05,06  ; block 5
db 00,01,02,03  ; block 6
db 41,41,40,40  ; block 7
db 42,41,40,40  ; block 8
db 42,42,40,40  ; block 9
db 41,42,40,40  ; block 10
db 43,43,43,43  ; block 11
db 32,33,32,33  ; block 12
db 12,12,40,40  ; block 13
db 45,44,47,46  ; block 14
db 45,48,47,48  ; block 15
db 43,45,43,47  ; block 16
db 44,43,46,43  ; block 17
db 48,44,48,46  ; block 18
db 48,48,48,48  ; block 19
db 49,49,49,49  ; block 20 
db 49,49,13,13  ; block 21
db 50,51,53,52  ; block 22
db 50,51,53,52  ; block 23
db 50,51,53,52  ; block 24
db 50,51,53,52  ; block 25
db 50,51,53,52  ; block 26
db 50,51,53,52  ; block 27
db 50,51,53,52  ; block 28

_spenemy:
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

_spplayerR0:   ; right frame 0
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

_spplayerR1:   ; right frame 1
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

_spplayerL0    ; left frame 0
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

_spplayerL1:    ; left frame 1
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
; void *p_sprites[3];
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
