.module tilemap


.globl posicion_inicio_pantalla_visible_sb
.globl posicion_inicio_pantalla_visible
.globl posicion_inicio_pantalla_visible2
.globl creascanes

.globl ancho_pantalla_bytes


.globl posicion_inicial_superbuffer


.globl _cpc_UpdTileTable



.globl _tiles
.globl _pantalla_juego
.globl _tiles_tocados
.globl _posiciones_pantalla
.globl _posiciones_super_buffer
.globl _tabla_y_ancho_pantalla


; .globl _ColumnScr


; ***************************************************
; Transparent colour for cpc_PutTrSpTileMap2b routine
;.globl _mascara1
;.globl _mascara2
; ***************************************************



; ***************************************************
; Scroll Left Addresses column
; not requiered if scroll not used
;.globl _ColumnScr
; ***********