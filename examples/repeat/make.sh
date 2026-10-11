#!/usr/bin/env bash

#
# This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
# and generate files that can be used in emulators or real  hardware for the Amstrad CPC
#
# USAGE: ./make.sh [clear]
#

MAKEHOME=$(dirname "$0")
ABASMHOME="$MAKEHOME/../.."

if [ -d "$ABASMHOME/bin" ]; then
    ASM="$ABASMHOME/bin/abasm"
    DSK="$ABASMHOME/bin/dsk"
    CDT="$ABASMHOME/bin/cdt"
    IMG="$ABASMHOME/bin/img"
else
    ASM="python $ABASMHOME/src/abasm.py"
    DSK="python $ABASMHOME/src/dsk.py"
    CDT="python $ABASMHOME/src/cdt.py"
    IMG="python $ABASMHOME/src/img.py"
fi

LOADADDR=0x4000
SOURCE=main
TARGET=repeat

RUNASM="$ASM --start=$LOADADDR $SOURCE.asm"
RUNDSK="$DSK $TARGET.dsk --new --put-bin $SOURCE.bin --load-addr $LOADADDR --map-file $SOURCE.map --start-addr MAIN"

if [ "$1" = "clear" ]; then
    rm -f "$SOURCE.bin"
    rm -f "$SOURCE.lst"
    rm -f "$SOURCE.map"
    rm -f "$TARGET.dsk"
else
    $RUNASM && $RUNDSK
fi
