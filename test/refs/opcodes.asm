; List of all instructions listed in the documentation
; Z80 Instruction Set section

org &4000

.main:

ADC   A,A
ADC   A,B       ;1 Add with carry register r to accumulator.
ADC   A,C
ADC   A,D
ADC   A,E
ADC   A,H
ADC   A,L
ADC   A,&FF     ;2 Add with carry value n to accumulator.
ADC   A,IXH     ;2 Add with carry high byte from IX to accumulator.
ADC   A,IXL
ADC   A,IYH
ADC   A,IYL
ADC   A,(HL)    ;2 Add with carry location (HL) to acccumulator.
ADC   A,(IX+0)  ;5 Add with carry location (IX+d) to accumulator.
ADC   A,(IY+0)  ;5 Add with carry location (IY+d) to accumulator.

ADC   HL,BC     ;4 Add with carry register pair BC to HL.
ADC   HL,DE     ;4 Add with carry register pair DE to HL.
ADC   HL,HL     ;4 Add with carry register pair HL to HL.
ADC   HL,SP     ;4 Add with carry register pair SP to HL.

ADD   A,A       ;1 Add register r to accumulator.
ADD   A,B
ADD   A,C
ADD   A,D
ADD   A,E
ADD   A,H
ADD   A,L
ADD   A,&FF     ;2 Add value n to accumulator.
ADD   A,IXH     ;2 Add high byte from IX to accumulator.
ADD   A,IXL     ;2 Add low byte from IX to accumulator.
ADD   A,IYH     ;2 Add high byte from IY to accumulator.
ADD   A,IYL     ;2 Add low byte from IY to accumulator.
ADD   A,(HL)    ;2 Add location (HL) to acccumulator.
ADD   A,(IX+0)  ;5 Add location (IX+d) to accumulator.
ADD   A,(IY+0)  ;5 Add location (IY+d) to accumulator.

ADD   HL,BC     ;3 Add register pair BC to HL.
ADD   HL,DE     ;3 Add register pair DE to HL.
ADD   HL,HL     ;3 Add register pair HL to HL.
ADD   HL,SP     ;3 Add register pair SP to HL.

ADD   IX,BC     ;4 Add register pair BC to IX.
ADD   IX,DE     ;4 Add register pair DE to IX.
ADD   IX,IX     ;4 Add register pair IX to IX.
ADD   IX,SP     ;4 Add register pair SP to IX.
ADD   IY,BC     ;4 Add register pair BC to IY.
ADD   IY,DE     ;4 Add register pair DE to IY.
ADD   IY,IY     ;4 Add register pair IY to IY.
ADD   IY,SP     ;4 Add register pair SP to IY.

AND   A         ;1 Logical AND of register r to accumulator.
AND   B
AND   C
AND   D
AND   E
AND   H
AND   L
AND   &FF       ;2 Logical AND of value n to accumulator.
AND   IXH       ;2 Logical AND of IX high byte to accumulator.
AND   IXL       ;2 Logical AND of IX low byte to accumulator.
AND   IYH       ;2 Logical AND of IY high byte to accumulator.
AND   IYL       ;2 Logical AND of IY low byte to accumulator.
AND   (HL)      ;2 Logical AND of value at location (HL) to accumulator.
AND   (IX+0)    ;5 Logical AND of value at location (IX+d) to accumulator.
AND   (IY+0)    ;5 Logical AND of value at location (IY+d) to accumulator.

BIT   7,A       ;2 Test bit b of register r.
BIT   7,B
BIT   7,C
BIT   7,D
BIT   7,E
BIT   7,H
BIT   7,L
BIT   7,(HL)    ;3 Test bit b of location (HL).
BIT   7,(IX+0)  ;6 Test bit b of location (IX+d).
BIT   7,(IY+0)  ;6 Test bit b of location (IY+d).

CALL  main      ;5 Call subroutine at location.
CALL  z,main  ;3/5 Call subroutine at location nn if condition CC is true (5) else (3).
CALL  nz,main
CALL  c,main
CALL  nc,main
CALL  p,main
CALL  m,main
CALL  pe,main
CALL  po,main

CCF             ;1 Complement carry flag.

CP    A         ;1 Compare register r with accumulator.
CP    B
CP    C
CP    D
CP    E
CP    H
CP    L
CP    IXH
CP    IXL
CP    IYH
CP    IYL
CP    &FF       ;2 Compare value n with accumulator.
CP    (HL)      ;2 Compare value at location (HL) with accumulator.
CP    (IX+0)    ;5 Compare value at location (IX+d) with accumulator.
CP    (IY+0)    ;5 Compare value at location (IY+d) with accumulator.

CPD             ;5 Compare location (HL) and acc., decrement HL and BC,
CPDR          ;5/6 Perform a CPD and repeat until BC=0 (5), if BC<>0 (6).
CPI             ;5 Compare location (HL) and acc., incr HL, decr BC.
CPIR          ;5/6 Perform a CPI and repeat until BC=0 (5), if BC<>0 (6).
CPL             ;1 Complement accumulator (1's complement).

DAA             ;1 Decimal adjust accumulato

DEC   A         ;1 Decrement register r.
DEC   B
DEC   C
DEC   D
DEC   E
DEC   H
DEC   L
DEC   IXH       ;2 Decrement IX high byte.
DEC   IXL       ;2 Decrement IX low byte.
DEC   IYH       ;2 Decrement IY high byte.
DEC   IYL       ;2 Decrement IY low byte.
DEC   (HL)      ;3 Decrement value at location (HL).
DEC   (IX+0)    ;6 Decrement value at location (IX+d).
DEC   (IY+0)    ;6 Decrement value at location (IY+d).

DEC   BC        ;2 Decrement register pair BC.
DEC   DE        ;2 Decrement register pair DE.
DEC   HL        ;2 Decrement register pair HL.
DEC   IX        ;3 Decrement IX.
DEC   IY        ;3 Decrement IY.
DEC   SP        ;2 Decrement register pair SP.

DI              ;1 Disable interrupts. (except NMI at 0066h)
DJNZ  @-10      ;3/4 Decrement B and jump relative if B<>0 (4) else (3).
EI              ;1 Enable interrupts.

EX    AF,AF'    ;1 Exchange the contents of AF and AF'.
EX    DE,HL     ;1 Exchange the contents of DE and HL.
EX    (SP),HL   ;6 Exchange the location (SP) and HL.
EX    (SP),IX   ;7 Exchange the location (SP) and IX.
EX    (SP),IY   ;7 Exchange the location (SP) and IY.
EXX             ;1 Exchange the contents of BC,DE,HL with BC',DE',HL'.

IM    0         ;2 Set interrupt mode 0. (instruction on data bus by int device)
IM    1         ;2 Set interrupt mode 1. (rst 38)
IM    2         ;2 Set interrupt mode 2. (vector jump)

IN    A,(&FA)  ;3 Load the accumulator with input from device/port n.
IN    B,(C)    ;4 Load the register r with input from device/port stored in B(!!).
IN    C,(C)    ; IN instruction uses the address stored in BC even if opcode only
IN    D,(C)    ; mentions C.
IN    E,(C)
IN    H,(C)
IN    L,(C)

INC   A         ;1 Increment register r.
INC   B
INC   C
INC   D
INC   E
INC   H
INC   L
INC   IXH       ;2 Increment IX high byte.
INC   IXL       ;2 Increment IX low byte.
INC   IYH       ;2 Increment IY high byte.
INC   IYL       ;2 Increment IY low byte.
INC   (HL)      ;3 Increment location (HL).
INC   (IX+0)    ;6 Increment location (IX+d).
INC   (IY+0)    ;6 Increment location (IY+d).

INC   BC        ;2 Increment register pair BC.
INC   DE        ;2 Increment register pair DE.
INC   HL        ;2 Increment register pair HL.
INC   IX        ;3 Increment IX.
INC   IY        ;3 Increment IY.
INC   SP        ;2 Increment register pair SP.

IND             ;5 (HL)=Input from port (C), Decrement HL and B.
INDR          ;5/6 Perform an IND and repeat until B=0 (5), if B<>0 (6).
INI             ;5 (HL)=Input from port (C), HL=HL+1, B=B-1.
INIR          ;5/6 Perform an INI and repeat until B=0 (5), if B<>0 (6).

JP    main      ;3 Unconditional jump to location nn.
JP    (HL)      ;1 Unconditional jump to location (HL).
JP    (IX)      ;2 Unconditional jump to location (IX).
JP    (IY)      ;2 Unconditional jump to location (IY).
JP    z,main    ;3 Jump to location nn if condition cc is true.
JP    nz,main
JP    c,main
JP    nc,main
JP    p,main
JP    m,main
JP    pe,main
JP    po,main

JR    @-10      ;3 Unconditional jump relative to PC+n.
JR    z,@-10  ;2/3 Jump relative to PC+n if zero (3) else (2).
JR    nz,@-10 ;2/3 Jump relative to PC+n if non zero (3) else (2).
JR    c,@-10  ;2/3 Jump relative to PC+n if carry=1 (3) else (2).
JR    nc,@-10 ;2/3 Jump relative to PC+n if carry=0 (3) else (2).

LD    A,A
LD    A,B
LD    A,C
LD    A,D
LD    A,E
LD    A,H
LD    A,L
LD    A,IXH
LD    A,IXL
LD    A,IYH
LD    A,IYL

LD    B,A
LD    B,B
LD    B,C
LD    B,D
LD    B,E
LD    B,H
LD    B,L
LD    B,IXH
LD    B,IXL
LD    B,IYH
LD    B,IYL

LD    C,A
LD    C,B
LD    C,C
LD    C,D
LD    C,E
LD    C,H
LD    C,L
LD    C,IXH
LD    C,IXL
LD    C,IYH
LD    C,IYL

LD    D,A
LD    D,B
LD    D,C
LD    D,D
LD    D,E
LD    D,H
LD    D,L
LD    D,IXH
LD    D,IXL
LD    D,IYH
LD    D,IYL

LD    E,A
LD    E,B
LD    E,C
LD    E,D
LD    E,E
LD    E,H
LD    E,L
LD    E,IXH
LD    E,IXL
LD    E,IYH
LD    E,IYL

LD    H,A
LD    H,B
LD    H,C
LD    H,D
LD    H,E
LD    H,H
LD    H,L

LD    L,A
LD    L,B
LD    L,C
LD    L,D
LD    L,E
LD    L,H
LD    L,L

LD    IXH,A
LD    IXH,B
LD    IXH,C
LD    IXH,D
LD    IXH,E
LD    IXL,A
LD    IXL,B
LD    IXL,C
LD    IXL,D
LD    IXL,E

LD    IYH,A
LD    IYH,B
LD    IYH,C
LD    IYH,D
LD    IYH,E
LD    IYL,A
LD    IYL,B
LD    IYL,C
LD    IYL,D
LD    IYL,E

LD    A,R       ;3 Load accumulator with R.(memory refresh register)
LD    A,I       ;3 Load accumulator with I.(interrupt vector register)
LD    A,(BC)    ;2 Load accumulator with value at location (BC).
LD    A,(DE)    ;2 Load accumulator with value at location (DE).
LD    A,(&FFFF) ;4 Load accumulator with value at location nn.

LD    I,A       ;3 Load I with accumulator.
LD    R,A       ;3 Load R with accumulator.
LD    A,(HL)    ;2 Load register r with value at location (HL).
LD    B,(HL)
LD    C,(HL)
LD    D,(HL)
LD    H,(HL)
LD    L,(HL)
LD    A,(IX+0)  ;5 Load register r with value at location (IX+d).
LD    B,(IX+0)
LD    C,(IX+0)
LD    D,(IX+0)
LD    E,(IX+0)
LD    H,(IX+0)
LD    L,(IX+0)
LD    A,(IY+0)  ;5 Load register r with value at location (IY+d).
LD    B,(IY+0)
LD    C,(IY+0)
LD    D,(IY+0)
LD    E,(IY+0)
LD    H,(IY+0)
LD    L,(IY+0)
LD    A,&FF    ;2 Load register r with value n.
LD    B,&FF
LD    C,&FF
LD    D,&FF
LD    E,&FF
LD    H,&FF
LD    L,&FF

LD    SP,HL     ;2 Load SP with HL.
LD    SP,IX     ;3 Load SP with IX.
LD    SP,IY     ;3 Load SP with IY.

LD    BC,&FFFF  ;3 Load register pair BC with nn.
LD    DE,&FFFF  ;3 Load register pair DE with nn.
LD    HL,&FFFF  ;3 Load register pair HL with nn.
LD    IX,&FFFF  ;4 Load IX with value nn.
LD    IY,&FFFF  ;4 Load IY with value nn.
LD    SP,&FFFF  ;3 Load register pair SP with nn.
LD    BC,(&FFFF);6 Load register pair BC with value at location (nn).
LD    DE,(&FFFF);6 Load register pair DE with value at location (nn).
LD    HL,(&FFFF);5 Load HL with value at location (nn), L-first.
LD    IX,(&FFFF);6 Load IX with value at location (nn).
LD    IY,(&FFFF);6 Load IY with value at location (nn).
LD    SP,(&FFFF);6 Load register pair SP with value at location (nn).

LD    (BC),A    ;2 Load location (BC) with accumulator.
LD    (DE),A    ;2 Load location (DE) with accumulator.
LD    (HL),&FF  ;3 Load location (HL) with value n.
LD    (HL),A    ;2 Load location (HL) with register r.
LD    (HL),B
LD    (HL),C
LD    (HL),D
LD    (HL),E
LD    (HL),H
LD    (HL),L
LD    (IX+0),&FF;6 Load location (IX+d) with value n.
LD    (IX+0),A  ;5 Load location (IX+d) with register r.
LD    (IX+0),B
LD    (IX+0),C
LD    (IX+0),D
LD    (IX+0),E
LD    (IX+0),H
LD    (IX+0),L
LD    (IY+0),&FF;6 Load location (IY+d) with value n.
LD    (IY+0),A  ;5 Load location (IY+d) with register r.
LD    (IY+0),B
LD    (IY+0),C
LD    (IY+0),D
LD    (IY+0),E
LD    (IY+0),H
LD    (IY+0),L

LD    (&FFFF),A ;4 Load location (nn) with accumulator.
LD    (&FFFF),BC;6 Load location (nn) with register pair BC.
LD    (&FFFF),DE;6 Load location (nn) with register pair DE.
LD    (&FFFF),HL;5 Load location (nn) with HL.
LD    (&FFFF),SP;6 Load location (nn) with register pair SP.
LD    (&FFFF),IX;6 Load location (nn) with IX.
LD    (&FFFF),IY;6 Load location (nn) with IY.

LDD             ;5 Load location (DE) with location (HL), decrement DE,HL,BC.
LDDR          ;5/6 Perform an LDD and repeat until BC=0 (5) else (6).
LDI             ;5 Load location (DE) with location (HL), incr DE,HL; decr BC.
LDIR          ;5/6 Perform an LDI and repeat until BC=0 (5) else (6).

NEG             ;2 Negate accumulator (2's complement).
NOP             ;1 No operation.

OR    A         ;1 Logical OR of register r and accumulator.
OR    B
OR    C
OR    D
OR    E
OR    H
OR    L
OR    IXH
OR    IXL
OR    IYH
OR    IYL
OR    &FF       ;2 Logical OR of value n and accumulator.
OR    (HL)      ;2 Logical OR of value at location (HL) and accumulator.
OR    (IX+0)    ;5 Logical OR of value at location (IX+d) and accumulator.
OR    (IY+0)    ;5 Logical OR of value at location (IY+d) and accumulator.

                ; OTDR and OTIR don't make much sense in AMSTRAD CPC
                ; because they use B and not C to store the port number.
OTDR          ;5/6 Perform an OUTD and repeat until B=0 (5) else (6).
OTIR          ;5/6 Perform an OTI and repeat until B=0 (5) else (6).
OUT   (C),A     ;4 Load output port stored in reg B(!!) with register r.
OUT   (C),C     ; !! This is perfectly valid in AMSTRAD CPC
OUT   (C),D
OUT   (C),E
OUT   (C),H
OUT   (C),L
OUT   (&FF),A   ;3 Load output port (n) with accumulator.
OUTD            ;5 Load output port in reg B(!!) with (HL), decrement HL and B.
OUTI            ;5 Load output port in reg B(!!) with (HL), incr HL, decr B.

POP   AF        ;3 Load register pair AF with top of stack.
POP   BC        ;3 Load register pair BC with top of stack.
POP   DE        ;3 Load register pair DE with top of stack.
POP   HL        ;3 Load register pair HL with top of stack.
POP   IX        ;5 Load IX with top of stack.
POP   IY        ;5 Load IY with top of stack.
PUSH  AF        ;4 Load register pair AF onto stack.
PUSH  BC        ;4 Load register pair BC onto stack.
PUSH  DE        ;4 Load register pair DE onto stack.
PUSH  HL        ;4 Load register pair HL onto stack.
PUSH  IX        ;5 Load IX onto stack.
PUSH  IY        ;5 Load IY onto stack.

RES   7,A       ;2 Reset bit b of register r.
RES   7,B
RES   7,C
RES   7,D
RES   7,E
RES   7,H
RES   7,L
RES   7,(HL)    ;4 Reset bit b in value at location (HL).
RES   7,(IX+0)  ;7 Reset bit b in value at location (IX+d).
RES   7,(IY+0)  ;7 Reset bit b in value at location (IY+d).

RET             ;3 Return from subroutine.
RET   z
RET   nz      ;2/4 Return from subroutine if condition cc is true (4) else (2).
RET   c
RET   nc
RET   p
RET   m
RET   pe
RET   po

RETI            ;4 Return from interrupt.
RETN            ;4 Return from non-maskable interrupt.

RL    A         ;2 Rotate left through register r.
RL    B
RL    C
RL    D
RL    E
RL    H
RL    L
RL    (HL)      ;4 Rotate left through value at location (HL).
RL    (IX+0)    ;7 Rotate left through value at location (IX+d).
RL    (IY+0)    ;7 Rotate left through value at location (IY+d).
RLA             ;4 Rotate left accumulator through carry.

RLC   A         ;2 Rotate register r left circular.
RLC   B
RLC   C
RLC   D
RLC   E
RLC   H
RLC   L
RLC   (HL)      ;4 Rotate location (HL) left circular.
RLC   (IX+0)    ;7 Rotate location (IX+d) left circular.
RLC   (IY+0)    ;7 Rotate location (IY+d) left circular.

RLCA            ;1 Rotate left circular accumulator.
RLD             ;5 Rotate digit left and right between accumulator and (HL).

RR    A         ;2 Rotate right through carry register r.
RR    B
RR    C
RR    D
RR    E
RR    H
RR    L
RR    (HL)      ;4 Rotate right through carry location (HL).
RR    (IX+0)    ;7 Rotate right through carry location (IX+d).
RR    (IY+0)    ;7 Rotate right through carry location (IY+d).

RRA             ;1 Rotate right accumulator through carry.

RRC   A         ;2 Rotate register r right circular.
RRC   B
RRC   C
RRC   D
RRC   E
RRC   H
RRC   L
RRC   (HL)      ;4 Rotate value at location (HL) right circular.
RRC   (IX+0)    ;7 Rotate value at location (IX+d) right circular.
RRC   (IY+0)    ;7 Rotate value at location (HL+d) right circular.

RRCA            ;1 Rotate right circular accumulator.
RRD             ;5 Rotate digit right and left between accumulator and (HL).

RST   &00       ;4 RESET. Reserved [2]. Resets the system.
RST   &08       ;4 LOW JUMP. Reserved [2]. Jumps to a routine in the lower 16K.
RST   &10       ;4 SIDE CALL. Reserved [2]. Calls a routine in an associated ROM.
RST   &18       ;4 FAR CALL. Reserved [2]. Calls a routine anywhere in memory.
RST   &20       ;4 RAM LAM. Reserved [2]. Reads the byte from RAM at the address of HL.
RST   &28       ;4 FIRM JUMP. Reserved [2]. Jumps to a routine in the lower ROM.
RST   &30       ;4 USER RST. Avaiable for the user to extend the instruction set.
RST   &38       ;4 INTERRUPT. Reserver [2]. Reserverd for interrupts.

SBC   A,A       ;1 Subtract register r from accumulator with carry.
SBC   A,B
SBC   A,C
SBC   A,D
SBC   A,E
SBC   A,H
SBC   A,L
SBC   A,IXH
SBC   A,IXL
SBC   A,IYH
SBC   A,IYL
SBC   A,&FF     ;2 Subtract value n from accumulator with carry.
SBC   A,(HL)    ;2 Subtract value at location (HL) from accu. with carry.
SBC   A,(IX+0)  ;5 Subtract value at location (IX+d) from accu. with carry.
SBC   A,(IY+0)  ;5 Subtract value at location (IY+d) from accu. with carry.
SBC   HL,BC     ;4 Subtract register pair BC from HL with carry.
SBC   HL,DE     ;4 Subtract register pair DE from HL with carry.
SBC   HL,HL     ;4 Subtract register pair HL from HL with carry.
SBC   HL,SP     ;4 Subtract register pair SP from HL with carry.

SCF             ;1 Set carry flag (C=1).

SET   7,A       ;2 Set bit b of register r.
SET   7,B
SET   7,C
SET   7,D
SET   7,E
SET   7,H
SET   7,L
SET   7,(HL)    ;4 Set bit b of location (HL).
SET   7,(IX+0)  ;7 Set bit b of location (IX+d).
SET   7,(IY+0)  ;7 Set bit b of location (IY+d).

SLA   A         ;2 Shift register r left arithmetic.
SLA   B
SLA   C
SLA   D
SLA   E
SLA   H
SLA   L
SLA   (HL)      ;4 Shift value at location (HL) left arithmetic.
SLA   (IX+0)    ;7 Shift value at location (IX+d) left arithmetic.
SLA   (IY+0)    ;7 Shift value at location (IY+d) left arithmetic.

SLL   A         ;2 Shift register r left logical.
SLL   B
SLL   C
SLL   D
SLL   E
SLL   H
SLL   L
SLL   (HL)      ;4 Shift value at location (HL) left logical.
SLL   (IX+0)    ;7 Shift value at location (IX+d) left logical.
SLL   (IY+0)    ;7 Shift value at location (IY+d) left logical.

SRA   A         ;2 Shift register r right arithmetic.
SRA   B
SRA   C
SRA   D
SRA   E
SRA   H
SRA   L
SRA   (HL)      ;4 Shift value at location (HL) right arithmetic.
SRA   (IX+0)    ;7 Shift value at location (IX+d) right arithmetic.
SRA   (IY+0)    ;7 Shift value at location (IY+d) right arithmetic.

SRL   A         ;2 Shift register r right logical.
SRL   B
SRL   C
SRL   D
SRL   E
SRL   H
SRL   L
SRL   (HL)      ;4 Shift value at location (HL) right logical.
SRL   (IX+0)    ;7 Shift value at location (IX+d) right logical.
SRL   (IY+0)    ;7 Shift value at location (IY+d) right logical.

SUB   A         ;1 Subtract register r from accumulator.
SUB   B
SUB   C
SUB   D
SUB   E
SUB   H
SUB   L
SUB   &FF       ;2 Subtract value n from accumulator.
SUB   IXH       ;2 Subtract IX high byte from accumulator.
SUB   IXL       ;2 Subtract IX low byte from accumulator.
SUB   IYH       ;2 Subtract IY high byte from accumulator.
SUB   IYL       ;2 Subtract IY low byte from accumulator.
SUB   (HL)      ;2 Subtract location (HL) from accumulator.
SUB   (IX+0)    ;5 Subtract location (IX+d) from accumulator.
SUB   (IY+0)    ;5 Subtract location (IY+d) from accumulator.

XOR   A         ;1 Exclusive OR register r and accumulator.
XOR   B
XOR   C
XOR   D
XOR   E
XOR   H
XOR   L
XOR   &FF       ;2 Exclusive OR value n and accumulator.
XOR   IXH       ;2 Exclusive OR IX high byte and accumulator.
XOR   IXL       ;2 Exclusive OR IX low byte and accumulator.
XOR   IYH       ;2 Exclusive OR IY high byte and accumulator.
XOR   IYL       ;2 Exclusive OR IY low byte and accumulator.
XOR   (HL)      ;2 Exclusive OR value at location (HL) and accumulator.
XOR   (IX+0)    ;5 Exclusive OR value at location (IX+d) and accumulator.
XOR   (IY+0)    ;5 Exclusive OR value at location (IY+d) and accumulator.