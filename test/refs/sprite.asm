; Include binary files example
; The code draws a 8x8 sprite imported as binary data
; it is based on http://www.chibiakumas.com/z80/simplesamples.php#LessonS1

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; ABASM call
;
; org &1200

; Check INCBIN directive
; the following sprite for MODE 1 is saved as binary format
; in the file sprite.bin

;test_sprite:
;    db %00110000, %11000000
;    db %01110000, %11100000
;    db %11110010, %11110100
;    db %11110000, %11110000
;    db %11110000, %11110000
;    db %11010010, %10110100
;    db %01100001, %01101000
;    db %00110000, %11000000
;
; [0x30,0xC0,0x70,0xE0,0xF2,0xF4,0xF0,0xF0,0xF0,0xF0,0xD2,0xB4,0x61,0x68,0x30,0xC0]

test_sprite: incbin "smile.bin"

draw_sprite_8x8:
    push hl
        ld a, (de)
        ld (hl), a
        inc de
        inc hl

        ld a, (de)
        ld (hl), a 
        inc de
    pop hl

    call &BC26  ; Firmware call to SCR_NEXT_LINE
    djnz draw_sprite_8x8
    ret

main:
    ; position X and Y
    ld de, &0010
    ld hl, &00A0

    call &BC1D ;SCR_DOT_POSITION

    ld de, test_sprite
    ld b, 8
    call draw_sprite_8x8

loop: jp loop
