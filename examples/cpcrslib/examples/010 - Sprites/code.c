#include "cpcrslib.h"

extern const char sprite[], buffer[];

void data(void){
__asm
_sprite:
.db #0x00,#0x60,#0x00
.db #0x00,#0xF0,#0x00
.db #0x10,#0xD0,#0xC0
.db #0x10,#0xF0,#0xE0
.db #0x10,#0xF0,#0xE0
.db #0x22,#0xE4,#0xC0
.db #0x33,#0x66,#0x00
.db #0x33,#0x77,#0x00
.db #0x33,#0x77,#0x00
.db #0x33,#0xCC,#0x00
.db #0x11,#0xEE,#0x00
.db #0x00,#0xFF,#0x00
.db #0x1F,#0x33,#0x00
.db #0x0D,#0x03,#0x0E
.db #0x0E,#0x0B,#0x0D
.db #0x05,#0x09,#0x0A

_buffer:
.db #0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0
__endasm;

}

main(){
    unsigned char buffer[16*3];
	cpc_SetModo(1); //rutina hardware, se restaura la situación anterior al terminar la ejecución del programa
	
    cpc_PrintGphStrXYM1("1;PUTS;A;SPRITE;IN;THE;SCREEN",0,8*23);
    cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
    while (!cpc_AnyKeyPressed()){}
	cpc_PutSp(sprite,16,3,0xc19b);
	// Captura de la pantalla el area indicada y la guarda en memoria.
    cpc_PrintGphStrXYM1("2;CAPTURES;A;SCREEN;AREA;;;;;",0,8*23);
    cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
    while (!cpc_AnyKeyPressed()){}
	cpc_GetSp(buffer,16,3,0xc19c);
    cpc_PrintGphStrXYM1("3;PRINTS;CAPTURED;AREA",0,8*23);
    cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
    while (!cpc_AnyKeyPressed()){}
	// En este ejemplo, imprime en &c19f el area capturada .
	cpc_PutSp(buffer,16,3,0xc19f);
	// Imprime el Sprite en modo XOR en la coordenada (x,y)=(100,50)
    cpc_PrintGphStrXYM1("4;PUTS;A SPRITE;IN;XOR;MODE",0,8*23);
    cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
    while (!cpc_AnyKeyPressed()){}
    cpc_PutSpXOR(sprite,16,3,cpc_GetScrAddress(100,50));
    cpc_PrintGphStrXYM1("5;SPRITE;PRINTED;AGAIN;IN;XOR;MODE",0,8*23);
    cpc_PrintGphStrXYM1("PRESS;ANY;KEY",0,8*24);
    while (!cpc_AnyKeyPressed()){}
    cpc_PutSpXOR(sprite,16,3,cpc_GetScrAddress(100,50));

    cpc_PrintGphStrXYM1(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;",0,8*23);
    cpc_PrintGphStrXYM1("THE;END;;;;;;",0,8*24);
    while(!(cpc_AnyKeyPressed())){}
}
