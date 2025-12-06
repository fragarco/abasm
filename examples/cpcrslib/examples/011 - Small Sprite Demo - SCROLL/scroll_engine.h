

/*

void drawColumnD(void)
{
    unsigned char i;
    unsigned int z,tt,yy;
    unsigned char y,t;
    z=(pointerH+28)>>1;		//situa en columna a leer
    i=(char)pointerH&1;
    pointerH++;
    for(y=0; y<7; y++)  	// recorre el alto de la pantalla
    {
        t=test_map2[TILES_ANCHO_TOT*y+z];  //busca tile
        tt=(t<<2)+i;
        yy=y<<1;
        cpc_SetTouchTileXY(26,yy,bloques[tt]);	// actualiza los tiles de la columna dcha correspondiente
        cpc_SetTouchTileXY(26,yy+1,bloques[tt+2]);
    }
}


void drawColumnI(void)
{
    unsigned char i;
    unsigned int z,tt,yy;
    unsigned char y,t;

    i=(char)pointerH&1;

    z=pointerH>>1;		//situa en columna a leer
    pointerH--;
    //if (i==0) i=1; else i=0;

//	draw_bloqueL(z,i);

    for(y=0; y<7; y++)
    {
        t=test_map2[TILES_ANCHO_TOT*y+z];
        tt=(t<<2)+i;
        yy=y<<1;
        cpc_SetTouchTileXY(0,yy,bloques[tt]);
        cpc_SetTouchTileXY(0,yy+1,bloques[tt+2]);
    }
}

*/


void drawColumnD(void)
{

    __asm
    xor a
    ld (paresI),a

    ld hl,(#_pointerH)
    push hl
    bit 0,l
    call nz,setParesI
    ld bc,#28         ; ancho tiles
    add hl,bc
    srl h
    rr l
    ld (#print_tileA+1),hl
    pop hl
    inc hl
    ld (#_pointerH),hl
    ld iy,#datos_scroll_CD     ; tiles 1 y 3
	
	push iy
	push ix
    call vetiles
	pop ix
	pop iy
    __endasm;

}


void drawColumnI(void)
{
    __asm
    xor a
    ld (paresI),a

    ld hl,(#_pointerH)
    bit 0,l
    call nz,setParesI
    push hl

    srl h
    rr l
    ld (#print_tileA+1),hl

    pop hl
    dec hl
    ld (#_pointerH),hl

    ld iy,#datos_scroll_CI      ; tiles 1 y 3
	
		push iy
	push ix
    call vetiles
	pop ix
	pop iy
	ret
	
vetiles:            ; correspendiendo a pantalla juego y superbuffer
    ld a,#7
bucle_ciA:
    push af
    ld l,0 (iy)
    ld h,1 (iy)
    ld (#tile3A+1),hl
    ld l,4 (iy)
    ld h,5 (iy)
    ld (#tile1A+1),hl


    ld l,2 (iy)
    ld h,3 (iy)
    ld (#tile3deA+1),hl
    ld l,6 (iy)
    ld h,7 (iy)
    ld (#tile1deA+1),hl


    ld l,8 (iy)
    ld h,9 (iy)         ; inicio datos en línea pantalla total
    call print_tileA

    ld de,#10
    add iy,de
    pop af
    dec a
    jp nz,bucle_ciA
    ret

setParesI:
    ld a,#0x23          ; PONER UN inC HL
    ld (#paresI),A
    ret

    ; HL línea correspondiente a los datos origen del mapa global
    ; BC tiene el número de columna a buscar
print_tileA:
    ld bc,#0000
    ld de,#_test_map2
    add hl,de
    add hl,bc
    ld l,(hl)   ; bloque
    ld h,#0
    add hl,hl
    add hl,hl
    ld de,#_bloques
    add hl,de           ; EN HL están los datos del bloque
paresI:
    NOP     ; INC HL = #0x23

                       push hl
                       pop ix ; apunta al bloque

    ld a,(hl)
tile1A:
    ld hl,#0000
    ld (hl),a
    ;; Y ahora se dibujan esos tiles en el buffer
tile1deA:
    ld de, #0000
    call dibuja_tile
tile3A:
    ld hl,#0000
    ld a,2 (ix)
    ld (hl),a
tile3deA:
    ld de, #0000
;    jp dibuja_tile
    ; ret

.db #0,#1,#2,#7
dibuja_tile:

    ; HL datos tile
    ; DE destino
    ;   push bc
    ld l,a
    ld h,#0
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL	; X16
    LD bc,#cpc_tiles
    ADD HL,bc

    ; tiles_composition_buffer + ancho * y + x




	ldi									;5
	ldi		;de<-hl						;5
	ex de,hl							;1
	ld bc,#54	; ancho - 2  (bytes)    ;3
	ld a,c
	add HL,BC							;3
	ex de,hl							;1
	ldi									;5
	ldi									;5
	ex de,hl							;1
	ld c,a				;2
	add HL,BC							;3
	ex de,hl							;1
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a
	add HL,BC
	ex de,hl
	ldi
	ldi
    ret

datos_scroll_CD:
    .dw #tiles_bgmap+28*1+26,#0x100+52+56*1*8
    .dw #tiles_bgmap+28*0+26,#0x100+52+56*0*8
    .dw #240*0
    .dw #tiles_bgmap+28*3+26,#0x100+52+56*3*8
    .dw #tiles_bgmap+28*2+26,#0x100+52+56*2*8
    .dw #240*1
    .dw #tiles_bgmap+28*5+26,#0x100+52+56*5*8
    .dw #tiles_bgmap+28*4+26,#0x100+52+56*4*8
    .dw #240*2
    .dw #tiles_bgmap+28*7+26,#0x100+52+56*7*8
    .dw #tiles_bgmap+28*6+26,#0x100+52+56*6*8
    .dw #240*3
    .dw #tiles_bgmap+28*9+26,#0x100+52+56*9*8
    .dw #tiles_bgmap+28*8+26,#0x100+52+56*8*8
    .dw #240*4
    .dw #tiles_bgmap+28*11+26,#0x100+52+56*11*8
    .dw #tiles_bgmap+28*10+26,#0x100+52+56*10*8
    .dw #240*5
    .dw #tiles_bgmap+28*13+26,#0x100+52+56*13*8
    .dw #tiles_bgmap+28*12+26,#0x100+52+56*12*8
    .dw #240*6
    .dw #tiles_bgmap+28*15+26,#0x100+52+56*15*8
    .dw #tiles_bgmap+28*14+26,#0x100+52+56*14*8
    .dw #240*7

datos_scroll_CI:
    .dw #tiles_bgmap+28*1,#0x100+56*1*8
    .dw #tiles_bgmap+28*0,#0x100+56*0*8
    .dw #240*0
    .dw #tiles_bgmap+28*3,#0x100+56*3*8
    .dw #tiles_bgmap+28*2,#0x100+56*2*8
    .dw #240*1
    .dw #tiles_bgmap+28*5,#0x100+56*5*8
    .dw #tiles_bgmap+28*4,#0x100+56*4*8
    .dw #240*2
    .dw #tiles_bgmap+28*7,#0x100+56*7*8
    .dw #tiles_bgmap+28*6,#0x100+56*6*8
    .dw #240*3
    .dw #tiles_bgmap+28*9,#0x100+56*9*8
    .dw #tiles_bgmap+28*8,#0x100+56*8*8
    .dw #240*4
    .dw #tiles_bgmap+28*11,#0x100+56*11*8
    .dw #tiles_bgmap+28*10,#0x100+56*10*8
    .dw #240*5
    .dw #tiles_bgmap+28*13,#0x100+56*13*8
    .dw #tiles_bgmap+28*12,#0x100+56*12*8
    .dw #240*6
    .dw #tiles_bgmap+28*15,#0x100+56*15*8
    .dw #tiles_bgmap+28*14,#0x100+56*14*8
    .dw #240*7
    __endasm;


}


