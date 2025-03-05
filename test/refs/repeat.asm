; Simple example of how to use FOR directive
; In this case we just fill 100 bytes with the value 0xFF

equ ENTITIES, 10
let ENTITY_ID = 0

main:
    ; let's generate a list of 10 elements with 3 bytes in
    ; each element
    entity_list:
    repeat ENTITIES
        db ENTITY_ID  ; Entity ID
        db &00        ; X pos
        db &00        ; Y pos
        LET ENTITY_ID = ENTITY_ID + 1  ; Next Entity ID
    rend

    ; Another example of creation of a list using WHILE
    obj_list:
    let OBJECTS = 10
    while OBJECTS>0
        db 10-OBJECTS   ; Object ID
        db 0            ; Object X pos
        db 0            ; Object Y pos
        LET OBJECTS = OBJECTS-1
    wend
