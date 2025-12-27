; Simple example of how to use REPEAT and WHILE directives
; The example doesn't show anything in the screen so it just
; entes in a endless loop. However, it is possible to see
; in the .lst file that the REPEAT and WHILE loops generate
; multiple "ENTITY" blocks

equ ENTITIES, 10
let ENTITY_ID = 0

main:
    jr main
    ; let's generate a list of 10 elements with 3 bytes in
    ; each element
    entity_list:
    repeat ENTITIES
        db ENTITY_ID  ; Entity ID
        db &00        ; X pos
        db &00        ; Y pos
        let ENTITY_ID = ENTITY_ID + 1  ; Next Entity ID
    rend

    ; Another example of creation of a list using WHILE
    obj_list:
    let OBJECTS = 10
    while OBJECTS>0
        db 10-OBJECTS   ; Object ID
        db 0            ; Object X pos
        db 0            ; Object Y pos
        let OBJECTS = OBJECTS-1
    wend
