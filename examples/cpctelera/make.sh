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

TARGET=cpctelera

if [ "$1" = "clear" ]; then
    rm -f *.bin
    rm -f *.lst
    rm -f *.map
    rm -f *.dsk
else
    FILES=(e01hello e02box e03struc e04hflip e05flipm e06card)
    ADDRS=(0x4000 0x4000 0x4000 0x4000 0x2000 0x2000)

    $DSK $TARGET.dsk --new    
    for i in  "${!FILES[@]}"
    do
        $ASM --start ${ADDRS[i]} ${FILES[i]}.asm && $DSK $TARGET.dsk --put-bin ${FILES[i]}.bin --load-addr=${ADDRS[i]} --start-addr=${ADDRS[i]}
    done
fi
