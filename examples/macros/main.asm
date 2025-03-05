; This example tries to show how macros are supported
; the syntax is the same used by WinAPE
;
; The macro code is taken from the excellent Framework
; CPCTelera:
; https://github.com/lronaldo/cpctelera

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; ABASM call
;
; org &1200

; REG16 = screenPtr
; In Python integer division is // so is here
macro get_videoPtr _R16_, _XCUR_, _YLINE_
   ld _R16_, &C000 + &50 * (_YLINE_ / 8) + &800 * (_YLINE_ MOD 8) + _XCUR_ * 2
endm

main:

   ; MODE 1
   ld a,l
   call &BC11 ;SCR_SET_MODE
   
   ; BORDER 2
   ld b,2      ; first color
   ld c,2      ; second color
   call &BC38  ;SCR_SET_BORDER")

   ; Let's draw three red lines of 4 pixels
   get_videoPtr hl,19,0
   ld (hl), &FF
   get_videoPtr hl,19,100
   ld (hl), &FF
   get_videoPtr hl,19,199
   ld (hl), &FF

endloop:
   jp endloop
