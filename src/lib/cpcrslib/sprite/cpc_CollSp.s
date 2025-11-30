.module sprites

.Globl _cpc_CollSp	

_cpc_CollSp::
;Get sprite structures from stack
	pop af
	pop iy	;ix sprite2 data
    pop ix	;iy sprite1 data   
	push af
    ;Sprite coords & sprite dims
				
;Get sprite dimensions from sprite data
	ld l,0 (ix)
	ld h,1 (ix)
	ld b,(hl)	;ancho a0
	inc hl
	ld c,(hl)	;alto a0

	ld l,0 (iy)
	ld h,1 (iy)
	ld d,(hl)	;ancho a1
	inc hl
	ld e,(hl)	;alto b1
	
;Check if both sprites collide
	Ld a, 8 (ix)		;A=xo
	sub d				;x0-a1
	cp 8 (iy)			;x1<x0-a1? está fuera
	jp nc, no_collision ;x1<A FUERA

	add b				
	add d				;xo+a0
	dec a
	cp 8 (iy)			;x1>xo+a0? está fuera
	jp c, no_collision  ;x1>A+a0+a1 FUERA

	Ld a, 9 (ix)		;A=yo
	sub e				;y0-b1
	cp 9 (iy)			;y1<A? está fuera
	jp nc, no_collision ;x1<A FUERA
	add e
	add c				;Y=y0+b0
	dec a
	cp 9 (iy)			;y1>y0+b0? está fuera
	jp c, no_collision  

collision:
	ld l,#1
	ret
no_collision:
	ld l,#0
	ret
	
