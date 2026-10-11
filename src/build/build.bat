@echo off

SET COMMON_FLAGS=--onefile -p..\ --distpath ..\..\bin

SET ABASM=pyinstaller ..\abasm.py %COMMON_FLAGS%
SET DSK=pyinstaller ..\dsk.py %COMMON_FLAGS%
SET CDT=pyinstaller ..\cdt.py %COMMON_FLAGS%
SET IMG=pyinstaller ..\img.py %COMMON_FLAGS%
SET ASMPRJ=pyinstaller ..\asmprj.py %COMMON_FLAGS%

CALL %ABASM% && CALL %DSK% && CALL %CDT% && CALL %IMG% && CALL %ASMPRJ%
@echo on