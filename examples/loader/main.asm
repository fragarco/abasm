; This example tries to show how CDT and DSK utilities
; can be used to store multiple files.
; In this case, a small program in BASIC and a binary
; routine that is called from such BASIC program.

org &8000

; This rutine is designed to be called from BASIC with CALL
strlen:
    ld l, (ix+0)
    ld h, (ix+1)
    ld a, (hl)
    ld c, (ix+2)
    ld b, (ix+3)
    ld (bc), a
    ret

