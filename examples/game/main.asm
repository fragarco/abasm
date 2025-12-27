; Star Sweeper!
; A Public Domain code from:
; https://www.cpcwiki.eu/index.php/Programming:Coding_a_simple_BASIC_game_into_Assembly
; Some comments and a BASIC version can be found in the previous web page.

; This example shows the WinAPE sintax support

; Instructions
; ============
 
; Simply dodge the oncomming rocks (bolders) hurdling towards you as
; you fly through space. 

; Controls are left or right arrow keys.

	org &8000

; Initialize Screen mode, inks & User Defined Graphics
main:
	xor a
	call &bc0e			; Mode 0

	ld hl,colours
	call setinks

	ld de,247
	ld hl,matrix_table
	call &bbab

	ld hl,sprites
	ld de,matrix_table
	ld bc,72
	ldir

	call genseed		; Randomize Seed

	ld a,1
	call &bb90			; Pen 1

	ld a,1
	call &bb9f			; Transparent Mode on

; Draw Obstacle Routine
; The game begins by Printing and scrolling the screen with 
; bolders on it. Once that has looped 24 times, the rocket and
; main game commence.

	ld b,24

drawobstacles
	push bc
	call rand
	call scalenum
	ld a,(result)
	ld (xpos1),a
	ld a,1
	ld (ypos1),a
	ld a,250
	ld (char),a
	ld a,4
	ld (col),a
	ld b,2	
	call print_spr
	call scroll
	call scroll
	pop bc
	djnz drawobstacles

	call printrocket

maingame

	call updaterocket

	ld a,(dead)
	or a
	jr z,skip

	ld a,1
	call &bb1e			; KM Test Key
	jr z,checkleft

	ld a,(xpos)
	cp 16
	jr z,checkleft
	inc a
	ld (xpos),a

	call printrocket

	ld a,(xpos)
	ld (ox),a

	ld hl,(ex)
	ld de,32
	add hl,de
	ld (ex),hl

checkleft
	ld a,8
	call &bb1e			; KM Test Key
	jr z,skip

	ld a,(xpos)
	cp 1
	jr z,skip
	dec a
	ld (xpos),a

	call printrocket

	ld a,(xpos)
	ld (ox),a

	ld hl,(ex)
	ld de,32
	and a
	sbc hl,de
	ld (ex),hl

skip ld a,(dead)
	and a
	jr nz,maingame

	xor a			; ld a,0
	call &bb9f

	ld hl,(ypos)
	call &bb75
	ld a,32
	call &bb5a

	ld a,1
	call &bb9f

	ld b,4
	ld a,252
	ld (char),a
	ld a,6
	ld (col),a
	ld hl,(ypos)
	ld (ypos1),hl
	call print_spr

	call explosion

	xor a			; ld a,0
	call &bb9f		; Transparent mode off
	call &bb03		; Clear Input (KM RESET)

	ld a,(dead)
	inc a
	ld (dead),a		; Reset Dead variable 

	ret			; Return to BASIC if this was launch with CALL

; Print Rocket Routine
; A routine dedicated to printing the rocket onscreeen.
; The print_spr routine works by using the transparent mode, redefined
; characters, pen colours & loops to produce a multicoloured 8x8 image.

printrocket
	ld hl,(ypos)
	ld (ypos1),hl
	ld a,247
	ld (char),a
	ld a,1
	ld (col),a
	ld b,3
	call print_spr
	ret	

; These routines handle the scrolling, collision tests and
; printing of rocket and bolders.

updaterocket
	call scroll
	call collision
	call scroll
	call printrocket
	call &bd19		;; FRAME (MC WAIT FLYBACK)
;	call updateobstacle
;	ret

updateobstacle
	call rand
	call scalenum
	ld a,(result)
	ld (xpos1),a
	ld a,1
	ld (ypos1),a
	ld a,250
	ld (char),a
	ld a,4
	ld (col),a
	ld b,2
	call print_spr
	ret

; Collision Detection
; In order to test if the rocket ship has collided with a bolder
; I've written a routine which tests for a pixel. Test is a 
; Graphical routine though, so in order to use this, I've setup
; ex and ey which holds the graphical positions in front and 
; above the rocket. ex had 12 added to it to allow the test to 
; return a non-zero result. When moving left or right with the 
; cursor keys ex is updated by either subtracting 32 or adding 
; 32.

collision
	ld hl,(ex)
	ex de,hl
	ld hl,(ey)
	call &bbf0		; TEST(ex,ey)
	or a			;	cp 0
	jr z,endcoll
	ld a,(dead)		;  
	dec a			; You're Dead
	ld (dead),a		;
endcoll
	ret

; Gen Seed routine
; Explained below

.genseed
	ld a,r
	ld (seed),a
	ret

; 8bit Random Number generator
; It takes a value stored in seed and returns a new number which gets 
; stored back into seed. In order make the routine a bit more random
; the Gen Seed routine is used to obtain a random value from the 
; refresh register (r). 

rand	ld a,(seed)
	ld b,a
	add a,a
	add a,a
	add a,b
	inc a
	ld (seed),a
	ret

; Setinks
; Entry Conditions:
;      hl = colours
; This just sets up a colour palette using a loop to increment through
; the PEN colours, c obtains the contents of hl which is the ink and is
; passed to b to prevent inks flashing. af & hl are pushed onto the stack
; because the SCR SET INK firmware alters these registers and pop restores
; them. When all 15 pens have been done, 'a' register is incremented if 
; this equals 16 then a jr c will not jump as there is no carry.

.setinks
	ld c,(hl)
	ld b,c
	push af
	push hl
	call &bc32		; SCR SET INK
	pop hl
	pop af
	inc hl
	inc a
	cp 16
	jr c,setinks
	ret

; Scroll Routine
; a = 0 to return a black background
; b = 0 to roll the screen top to bottom
; to make this game a little bit more challenging, I'm using SCR HW ROLL
; which rolls the screen very quickly. 
; To space out the bolders, I've called this routine twice, which has 
; produced this intense game, but it's always going to produce quite a 
; bit of flicker.

.scroll
	xor a
	ld b,a
	call &bc4d		; SCR HW ROLL
	ret

; Scale number routine
; This takes the number produced by the random number generator which is
; in the range between 1 & 255 I think, srl divides the number by 2 and 
; is done 4 times to return a number between 1 and 16.

.scalenum
	ld a,(seed)
	srl a
	srl a
	srl a
	srl a
	inc a
	ld (result),a
	ret

; Print Sprite routine
; Entry Conditions:
;	B = Number of times to Loop (3, 2 or 4)
;	Char = Sprite number (247 = Rocket, 250 = Bolder, 252 = Explosion)
;      Col = Sprite Pen Colours (1 = Rocket, 4 = Bolder, 6 = Explosion)
;	Xpos1 & Ypos1 = Positions of Sprites 

.print_spr
	ld a,(col)
	call &bb90
	ld hl,(ypos1)
	call &bb75
	ld a,(char)
	call &bb5a
	ld a,(col)
	inc a
	ld (col),a
	ld a,(char)
	inc a
	ld (char),a
	djnz print_spr
	ret

.explosion
	ld hl,snddata
	call &bcaa		; SND Queue
	ret

	
.ypos	defb 25
.xpos	defb 10
.ypos1	defb 1
.xpos1	defb 5
.ox	defb 10
.dead	defb 1
.seed	defb 0
.result defb 0
.ex	defw 300		; Test Pixel Colour 4x3 of xpos position, so xpos-1 x 32 = 288
.ey	defw 30
.char	defb 0
.col	defb 0
.snddata
	defb 1,0,0,0,0,31,15,10,0
.colours
	defb 0,13,26,6,15,3,3,6
	defb 24,26,0,0,0,0,0,0
.matrix_table
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0
	defb 0,0,0,0,0,0,0,0

; Sprite data

.sprites
	defb 24,36,90,90,36,102,0,0
	defb 0,24,36,36,24,24,0,0		; Rocket
	defb 0,0,0,0,0,0,90,0

	defb 28,34,65,129,129,65,34,28	; Bolder
	defb 0,28,62,126,126,62,28,0

	defb 24,36,66,66,66,36,24,0
	defb 0,24,36,36,36,24,0,0		; Explosion
	defb 0,0,8,24,24,0,0,0
	defb 0,0,16,0,0,0,0,0
.sprites_end
	defb 0
