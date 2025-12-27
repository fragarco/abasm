#!/bin/sh

#
# This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
# and generate files that can be used in emulators or real  hardware for the Amstrad CPC
#
# USAGE: ./make.sh [clear]
#

ASM="python3 ../../src/abasm.py"
DSK="python3 ../../src/dsk.py"

LOADADDR=0x4000
TARGET=cpcrslib

RUNASM="$ASM --start=$LOADADDR $SOURCE.asm"
RUNDSK="$DSK $TARGET.dsk --new --put-bin $SOURCE.bin --load-addr $LOADADDR --map-file $SOURCE.map --start-addr MAIN"

if [ "$1" = "clear" ]; then
    rm -f *.bin
    rm -f *.lst
    rm -f *.map
    rm -f *.dsk
else
    $DSK $TARGET.dsk --new
    for x in example1 example2 example3 example4 example5 
    do
        $ASM --start $LOADADDR $x.asm && $DSK $TARGET.dsk --put-bin $x.bin
    done
fi
