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

LOADADDR=0x1200
SOURCE=image
TARGET=img

if [ "$1" = "clear" ]; then
    rm -f "$SOURCE.scn"
    rm -f "$SOURCE.scn.info"
    rm -f "$TARGET.dsk"
else
    $IMG assets/logo_aua.jpg --format scn --mode 0 --name $SOURCE
    $DSK -n $TARGET.dsk --put-ascii loadimg.bas
    $DSK $TARGET.dsk --put-bin $SOURCE.scn
fi
