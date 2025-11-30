.module keyboard

.include "keyboard.s"

.globl _cpc_ScanKeyboard

_cpc_ScanKeyboard::

    DI              ;1 #0X#0X%%#0X#0X C P C   VERSION #0X#0X%%#0X#0X   FROM CPCWIKI
    LD HL,#keymap    ;3
    LD BC,#0XF782     ;3
    OUT (C),C       ;4
    LD BC,#0XF40E     ;3
    LD E,B          ;1
    OUT (C),C       ;4
    LD BC,#0XF6C0     ;3
    LD D,B          ;1
    OUT (C),C       ;4
    LD C,#0          ;2
    OUT (C),C       ;4
    LD BC,#0XF792     ;3
    OUT (C),C       ;4
    LD A,#0X40        ;2
    LD C,#0X4A        ;2 44
loop_cpc_scankeyboard:
	LD B,D          ;1
    OUT (C),A       ;4 SELECT LINE
    LD B,E          ;1
    INI             ;5 READ BITS AND WRITE INTO KEYMAP
    INC A           ;1
    CP C            ;1
    JR C,loop_cpc_scankeyboard       ;2/3 9*16+1*15=159
    LD BC,#0XF782     ;3
    OUT (C),C       ;4
    EI              ;1 8 =211 MICROSECONDS
    RET