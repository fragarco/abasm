#!/bin/sh

#
# This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
# and generate files that can be used in emulators or real  hardware for the Amstrad CPC
#
# USAGE: ./make.sh [clear]
#

DSK="python3 ../../src/dsk.py"
IMG="python3 ../../src/img.py"

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
