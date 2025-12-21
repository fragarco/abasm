#!/bin/bash

# *
# * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
# * and generate files that can be used in emulators or new hardware for the Amstrad CPC
# *
# * USAGE: ./make.sh [clear]

set -e

ASM="python3 ../../src/abasm.py $@"
DSK="python3 ../../src/dsk.py"

LOADADDR=0x2000
TARGET=cpctelera

if [ "$1" = "clear" ]; then
    rm -f *.bin *.lst *.map *.dsk
else
    $DSK "$TARGET.dsk" --new

    for x in e01hello e02box e03struc e04hflip e05flipm e06card; do
        $ASM --start $LOADADDR "$x.asm" && \
        $DSK "$TARGET.dsk" --put-bin "$x.bin" --load-addr=$LOADADDR --start-addr=$LOADADDR
    done
fi
