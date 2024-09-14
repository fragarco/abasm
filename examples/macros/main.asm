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
macro cpctm_screenPtr REG16, VMEM, X, Y 
   ld REG16, VMEM + 80 * (Y / 8) + 2048 * (Y & 7) + X 
endm

main:
   cpctm_screenPtr hl,0xC000,20,10
   ld (hl), &FF

endloop:
   jp endloop
