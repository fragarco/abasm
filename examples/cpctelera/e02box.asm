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

;; Include all CPCtelera definitions and variables
read 'cpctelera/firmware/cpct_removeInterruptHandler.asm'
read 'cpctelera/memutils/cpct_memset.asm'
read 'cpctelera/video/video_macros.asm'
read 'cpctelera/video/cpct_getScreenPtr.asm'
read 'cpctelera/strings/cpct_drawStringM1_f.asm'
read 'cpctelera/strings/cpct_drawCharM1_f.asm'
read 'cpctelera/keyboard/cpct_scanKeyboard.asm'
read 'cpctelera/keyboard/cpct_isAnyKeyPressed.asm'
read 'cpctelera/sprites/cpct_drawSolidBox.asm'

str_press: db "Please, press any key.",0

;; Declare all function entry points as global symbols for the compiler
;; (The linker will know what to do with them)
;.globl cpct_memset_asm
;.globl cpct_drawSolidBox_asm
;.globl cpct_isAnyKeyPressed_asm  
;.globl cpct_scanKeyboard_asm 
;.globl cpct_drawStringM1_f_asm
;.globl cpct_disableFirmware_asm
;.globl cpct_getScreenPtr_asm

;;
;; MAIN function. This is the entry point of the application.
;;
main:
   ;; Disable firmware to prevent it from interfering with string drawing
   call cpct_removeInterruptHandler

   ;; Clear the screen (in red)
   ld   de, &C000   ;; DE = Pointer to video memory location to start copying bytes
   ld   bc, &4000   ;; BC = 0x4000 (16K) bytes to copy (full video memory)
   ld    a, &FF     ;; A  = 0xFF, Colour pattern (3, 3, 3, 3)
   
   call cpct_memset ;; Fill up video memory with colour pattern

   ;; Calculate a location for printing a string
   ld   de, &C000   ;; DE = Pointer to start of the screen
   ld   bc, &1810   ;; B  = y coordinate (0x18 = 24), C = x coordinate (0x10 = 16)

   call cpct_getScreenPtr ;; Calculate video memory location and return it in HL

   ;; Print a string to ask the user for pressing Space
   ex   de, hl         ;; Interchange HL <-> DE to make DE = Pointer to video memory where string will be drawn
   ld   hl, str_press  ;; HL = Pointer to the string 
   ld   bc, &0300      ;; B  = Background PEN (3), C = Foreground PEN (0)

   call cpct_drawStringM1_f  ;; Draw the string

   ;; Wait for the user to press a Key
loop:
   call cpct_scanKeyboard    ;; Scan the keyboard

   call cpct_isAnyKeyPressed ;; Check for any key being pressed
   or   a                    ;; If A key is pressed, A != 0
   jr   z, loop              ;; When A=0, No key is pressed, Loop again

   ;; Draw a Box
   ld   de, &C325  ;; DE = Pointer to video memory location where the box will be drawn
   ld   bc, &140A  ;; B = Height (20 = 0x14), C = Width (10 = 0x0A)
   ld    l, &AA    ;; L = Colour Pattern (0xAA = 3, 0, 3, 0)

   call cpct_drawSolidBox ;; Call the box drawing function

   ;; Draw another Box
   ld   de, &C335  ;; DE = Pointer to video memory location where the box will be drawn
   ld   bc, &140A  ;; B = Height (20 = 0x14), C = Width (10 = 0x0A)
   ld    l, &A0    ;; L = Colour Pattern (0xA0 = 1, 0, 1, 0)

   call cpct_drawSolidBox ;; Call the box drawing function

   ;; Draw a third Box
   ld   de, &C345  ;; DE = Pointer to video memory location where the box will be drawn
   ld   bc, &140A  ;; B = Height (20 = 0x14), C = Width (10 = 0x0A)
   ld    l, &0A    ;; L = Colour Pattern (0xAA = 2, 0, 2, 0)

   call cpct_drawSolidBox ;; Call the box drawing function

forever:
   jr forever        ;; Infinite waiting loop
