@echo off
REM Example batch file that converts Markdown files to HTML
REM using PANDOC (must be present in the system) and its default HTML template.

SET PANDOC=pandoc --standalone --variable=maxwidth:50em

IF "%1"=="clear" (
    del .\en\*.html
    del .\es\*.html
) ELSE ( 
    %PANDOC% .\en\abasm.md -o .\en\abasm.html
    %PANDOC% .\en\asmprj.md -o .\en\asmprj.html
    %PANDOC% .\en\cdt.md -o .\en\cdt.html
    %PANDOC% .\en\dsk.md -o .\en\dsk.html
    %PANDOC% .\en\dsk.md -o .\en\bindiff.html

    %PANDOC% .\es\abasm.md -o .\es\abasm.html
    %PANDOC% .\es\asmprj.md -o .\es\asmprj.html
    %PANDOC% .\es\cdt.md -o .\es\cdt.html
    %PANDOC% .\es\dsk.md -o .\es\dsk.html
    %PANDOC% .\en\dsk.md -o .\es\bindiff.html
)

@echo on
