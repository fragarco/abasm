.module sprites

.include "sprites.s"



_int_cpc_PutTile2x80:
		;LD A,8

		.db #0xdD
   		LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		ld b,#7
		
	loop_alto_tile_2x8:
	loop_ancho_tile_2x8:		
		ld A,(DE)
		ld (hl),a
		inc de
		inc hl
		
		ld A,(DE)
		ld (hl),a
		inc de
		;inc hl

	   .db #0xdD
	   dec H
	   ret z
	   
suma_siguiente_linea0_tile_2x8:		
		LD C,#0xff			;&07f6 			salto linea menos ancho
		
		ADD HL,BC
		jp nc,loop_alto_tile_2x8 ;sig_linea_2zz		si no desborda va a la siguiente linea
		
		ld bc,#0xc050
		
		add HL,BC
		ld b,#7			;sólo se daría una de cada 8 veces en un sprite
		jp loop_alto_tile_2x8	