echo off
IF "%1"=="" GOTO Continue


sdcc -mz80 --code-loc 0x6038 --data-loc 0 --no-std-crt0  crt0_cpc.rel   -l cpcrslib.lib %1.c
hex2bin %1.ihx

copy %1.bin d:\WinApe

GOTO End

:Continue


echo Syntax:  make filename   (without extension)


:End