10 ' loader for SCN image
20 mode 0
30 ' set palette
40 ink 0,26:ink 1,13:ink 2,0:ink 3,14:ink 4,16:ink 5,22:ink 6,10:ink 7,2
50 ink 8,18:ink 9,6:ink 10,3:ink 11,1:ink 12,9:ink 13,12:ink 14,21:ink 15,4
70 load "!image.scn", &C000
80 goto 80
