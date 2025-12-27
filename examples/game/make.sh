#!/bin/sh

#
# This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
# and generate files that can be used in emulators or real  hardware for the Amstrad CPC
#
# USAGE: ./make.sh [clear]
#

ASM="python3 /Users/javi/workspace/github/abasm/src/abasm.py"
DSK="python3 /Users/javi/workspace/github/abasm/src/dsk.py"

LOADADDR=0x8000
SOURCE=main
TARGET=game

RUNASM="$ASM --start=$LOADADDR $SOURCE.asm"
RUNDSK="$DSK $TARGET.dsk --new --put-bin $SOURCE.bin --load-addr $LOADADDR --map-file $SOURCE.map --start-addr MAIN"

if [ "$1" = "clear" ]; then
    rm -f "$SOURCE.bin"           "$SOURCE.lst"           "$SOURCE.map"           "$TARGET.dsk"
else
    $RUNASM && $RUNDSK
fi
