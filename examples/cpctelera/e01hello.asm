;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2015 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

;; Code modified to be used with ABASM by Javier "Dwayne Hicks" Garcia

org &4000
jp  main

;; Define a welcome string message
string: db "Welcome to CPCtelera in ASM!",0

;; Include all CPCtelera definitions and variables
read 'cpctelera/firmware/cpct_removeInterruptHandler.asm'
read 'cpctelera/strings/cpct_drawStringM1.asm'
read 'cpctelera/strings/cpct_setDrawCharM1.asm'

;;
;; MAIN function. This is the entry point of the application.
;;    _main:: global symbol is required for correctly compiling and linking
;;
main:
   ;; Disable firmware to prevent it from interfering with drawString
   call cpct_disableFirmware

   ;; Before calling drawstring, we first need to set up the PEN colours
   ;; we want to use for drawing, by calling cpct_setDrawCharM1_asm
   ld   d, 00   ;; Set Background PEN to 0 (BLUE)
   ld   e, 03   ;; Set Foreground PEN to 3 (RED)

   call cpct_setDrawCharM1 ;; Set up colours for drawn characters in mode 1

   ;; We are going to call draw String, and we have to push parameters
   ;; to the stack first (as the function recovers it from there).
   ld   iy, string  ;; IY = Pointer to the start of the string
   ld   hl, &C280   ;; HL = Pointer to video memory location where the string will be drawn

   call cpct_drawStringM1 ;; Call the string drawing function

forever:
   jp forever        ;; Infinite waiting loop
