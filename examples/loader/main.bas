10 ' This loader loads the binary file in the memory address 0x8000
20 ' and then ask the user for an string.
30 ' The binary code is just a simple function that reads the first
40 ' byte as Locomotive BASIC stores there the length of the string.
50 SYMBOL AFTER 256: MEMORY &8000
60 SYMBOL AFTER 240: CLS
70 LOAD "!MAIN.BIN", &8000
80 INPUT "Write your string: ";a$
90 strlen%=0
100 CALL &8000,@strlen%,@a$
110 PRINT "The length of your string is: ";strlen%
