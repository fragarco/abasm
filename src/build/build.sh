#!/usr/bin/env bash

SCRIPTDIR=$(dirname "$0")

COMMON_FLAGS="--onefile -p$SCRIPTDIR/../ --distpath $SCRIPTDIR/../../bin"

ABASM="pyinstaller $SCRIPTDIR/../abasm.py $COMMON_FLAGS"
DSK="pyinstaller $SCRIPTDIR/../dsk.py $COMMON_FLAGS"
CDT="pyinstaller $SCRIPTDIR/../cdt.py $COMMON_FLAGS"
IMG="pyinstaller $SCRIPTDIR/../img.py $COMMON_FLAGS"
ASMPRJ="pyinstaller $SCRIPTDIR/../asmprj.py $COMMON_FLAGS"

$ABASM && $DSK && $CDT && $IMG && $ASMPRJ

rm -rd "$SCRIPTDIR/../../bin/lib"
cp -R "$SCRIPTDIR/../lib/" "$SCRIPTDIR/../../bin/lib/"