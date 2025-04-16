; The code just redefines a label but this case should be supported as
; the second definition is inside an IF block that should not produce code

; org &1200

let OPTION = 1
let value = 1
test_label DB  &00


if OPTION = 0
    let value = 0
elseif OPTION = 2
    let value = 2
endif

if value != 1
    test_label DB &FF
endif
