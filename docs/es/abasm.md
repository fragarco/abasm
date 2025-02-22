- [Introducción](#introducción)
  - [¿Por qué otro ensamblador para Amstrad?](#por-qué-otro-ensamblador-para-amstrad)
- [Cómo se usa](#cómo-se-usa)
  - [Opciones disponibles](#opciones-disponibles)
  - [Ejemplos de uso](#ejemplos-de-uso)
- [Productos del ensamblado](#productos-del-ensamblado)
  - [El archivo binario](#el-archivo-binario)
  - [Listado del programa](#listado-del-programa)
  - [Archivo de símbolos](#archivo-de-símbolos)
- [Sintaxis](#sintaxis)
  - [Comentarios](#comentarios)
  - [Etiquetas](#etiquetas)
  - [Instrucciones](#instrucciones)
  - [Directivas del Ensamblador](#directivas-del-ensamblador)
    - [ALIGN](#align)
    - [ASSERT](#assert)
    - [DB, DM, DEFB, DEFM](#db-dm-defb-defm)
    - [DS, DEFS, RMEM](#ds-defs-rmem)
    - [DW, DEFW](#dw-defw)
    - [EQU](#equ)
    - [IF](#if)
    - [INCBIN](#incbin)
    - [MACRO](#macro)
    - [LET](#let)
    - [LIMIT](#limit)
    - [READ](#read)
    - [REPEAT](#repeat)
    - [ORG](#org)
    - [PRINT](#print)
    - [SAVE](#save)
    - [STOP](#stop)
    - [WHILE](#while)
  - [Expresiones y Caracteres Especiales](#expresiones-y-caracteres-especiales)
- [Historial de cambios](#historial-de-cambios)


# Introducción

ABASM es un ensamblador cruzado diseñado específicamente para la plataforma Amstrad CPC y su CPU Z80. Desarrollado en Python 3, su principal objetivo es proporcionar una herramienta ligera y altamente portable para programadores interesados en crear código ensamblador para esta clásica plataforma de 8 bits. Al no depender de librerías externas ni herramientas de terceros, ABASM puede ejecutarse en cualquier sistema que cuente con un intérprete de Python 3. Además, el proyecto incluye otras herramientas, también programadas en Python y sin dependencias, para empaquetar el resultado del ensamblador en archivos DSK o CDT.

ABASM está basado en el fantástico proyecto pyZ80, creado inicialmente por Andrew Collier y modificado posteriormente por Simon Owen.

## ¿Por qué otro ensamblador para Amstrad?

ABASM surge de la idea de contar con una herramienta portable y fácil de modificar por cualquiera, sin depender de sistemas operativos específicos o entornos de desarrollo particulares. Uno de sus objetivos es proporcionar una sintaxis compatible con el antiguo ensamblador MAXAM, con la sintaxis de WinAPE y con la de Virtual Machine Simulator. De esta forma, los desarrolladores pueden contar con varias opciones para depurar su código durante el desarrollo.

En cualquier caso, si lo que buscas es eficiencia en vez de portabilidad y facilidad de modificación, quizás quieras probar estos otros ensambladores:

* [Pasmo](https://pasmo.speccy.org/)
* [ASZ80](https://shop-pdp.net/ashtml/)
* [Rasm](https://github.com/EdouardBERGE/rasm)

# Cómo se usa

Para ensamblar un archivo fuente de código en ensamblador (por ejemplo, `program.asm`), basta con ejecutar el siguiente comando:

```
python3 ABASM.py <program.asm> [opciones]
```

Este comando ensamblará el archivo `program.asm` y generará un fichero binario con el mismo nombre, `program.bin`.

## Opciones disponibles

- `-d` o `--define`: Permite definir pares `SÍMBOLO=VALOR`. Dichos símbolos pueden utilizarse en el código como constantes o etiquetas. Esta opción se puede emplear múltiples veces para definir varios símbolos.
- `--start`: Define la dirección de memoria que se tomará como punto de inicio para la carga del programa. Por defecto, esta dirección es `0x4000`, aunque también puede establecerse directamente dentro del código usando la directiva `ORG`.
- `-o` o `--output`: Especifica el nombre del archivo binario de salida. Si no se utiliza esta opción, se empleará el nombre del archivo de entrada cambiando su extensión por `.bin`.
- `-v` o `--version`: Muestra el número de versión de ABASM.
- `--verbose`: Imprime mucha más información por consola durante el proceso de ensamblado. 

## Ejemplos de uso

Definir una constante utilizada en el código:

```
python3 ABASM.py program.asm -d MY_CONSTANT=100
```

Establecer el nombre exacto del archivo binario ensamblado:

```
python3 ABASM.py program.asm -o output.bin
```

Establecer la dirección de inicio en memoria que debe considerarse para el cálculo de los saltos y otras referencias relativas utilizadas en el código fuente, por ejemplo, a `0x2000`:

```
python3 ABASM.py program.asm --start 0x2000
```

¡Claro! Aquí tienes el texto original en español con las correcciones ortográficas y gramaticales realizadas para mejorar el estilo:

---

# Productos del ensamblado

Una ejecución exitosa de ABASM genera varios archivos. En esta sección se proporciona una breve explicación de cada uno de dichos productos.

## El archivo binario

El resultado final del proceso de ensamblado es un archivo binario (normalmente con la extensión `.BIN`) listo para su carga en memoria y ejecución en un Amstrad CPC. El código fuente puede dividirse en varios archivos, pero solo uno, el principal, se pasa como parámetro a ABASM para iniciar el ensamblado. El resto de archivos se añadirán a medida que se referencien mediante las directivas `READ` o `INCBIN`.

ABASM no genera código relocalizable, lo que significa que asume una dirección inicial de carga en memoria. Esta dirección de carga puede indicarse como un parámetro en la llamada a ABASM o puede establecerse en el propio archivo principal mediante la directiva `ORG`.

Por ejemplo, el siguiente código en ensamblador, que carga el valor `0xFF` en la primera posición de la memoria de vídeo, generaría el contenido binario que se muestra a continuación (como una secuencia de valores en hexadecimal).

```
org  0x4000       ; Fijamos la dirección inicial de carga en memoria

main:
    ld   a,0xFF       ; Cargamos en el acumulador el valor 0xFF
    ld   (0xC000),a   ; Cargamos en el primer byte de la memoria 
                      ; de vídeo el contenido de A
endloop:              ; Bucle infinito
    jp endloop        ; El valor de 'endloop' se calculará 
                      ; según el valor inicial indicado por ORG
```

```
3E FF 32 00 C0 C3 05 40
```

Dado que el Z80 es *little-endian*, podemos ver que los últimos tres bytes son `C3 05 40`, lo que equivale a `C3 4005`, que es el resultado en código máquina para `jp endloop`, con `endloop` calculado a partir de la dirección de inicio `0x4000`.

## Listado del programa

Como referencia para el programador, el proceso de ensamblado también genera un archivo con el listado del programa original y el resultado binario de cada una de las instrucciones. La extensión de este archivo es `.LST`.

Siguiendo con el ejemplo proporcionado anteriormente, el archivo `.LST` generado tendría el siguiente contenido:

```
main.asm      000001  4000               	org  0x4000
main.asm      000002  4000               	main
main.asm      000003  4000  3E FF        	ld   a, 0xFF
main.asm      000004  4002  32 00 C0     	ld  (0xC000), a
main.asm      000005  4005               	endloop
main.asm      000006  4005  C3 05 40     	jp endloop
```

El nombre del archivo origen aparece en la primera columna, mientras que la segunda indica el número secuencial de la instrucción en dicho archivo. La tercera columna indica qué posición de memoria ocupar el código generado (si se ha generado alguno, ya que algunas directivas y etiquetas no generan código binario). La cuarta columna muestra el código binario resultante de ensamblar la instrucción y la última columna la instrucción original.

## Archivo de símbolos

ABASM también genera un listado de todos los símbolos globales encontrados y su valor asociado. La mayoría de ellos serán etiquetas utilizadas para marcar posiciones de salto o ubicaciones de memoria donde se han almacenado ciertos datos. Los símbolos locales son aquellos que comienzan con el caracter '.'.

La extensión del fichero de símbolos es `.MAP` y su formato es el de un diccionario de Python. Esto permite emplear el archivo en otras utilidades (como los empaquetadores DSK y CDT) y utilizar los símbolos en lugar de sus valores. En la documentación sobre las utilidades DSK y CDT se puede encontrar un ejemplo de uso de este archivo.

```
# Lista de símbolos en formato de diccionario de Python
# Símbolo: [dirección, número total de consultas (usos), nombre del archivo]
{
	"ENDLOOP": [0x4005, 2, "MAIN.ASM"],
	"MAIN": [0x4000, 1, "MAIN.ASM"],
}
```

# Sintaxis

La sintaxis de ABASM está diseñada para asemejarse lo máximo posible a la del ensamblador MAXAM. Esta sintaxis es bastante compatible con la soportada por el simulador WinAPE. Además, ABASM admite algunas variaciones que también lo hacen compatible con la sintaxis utilizada por el simulador Retro Virtual Machine. El objetivo es permitir que los desarrolladores cuenten con varias herramientas para la depuración y prueba de sus programas.

A continuación se muestra un ejemplo sencillo de un programa escrito utilizando la sintaxis de ABASM. Este ejemplo muestra tres de los elementos básicos de cualquier programa escrito en ensamblador: etiquetas, instrucciones y comentarios. Un cuarto elemento serían las directivas del ensamblador, comandos dirigidos al propio ABASM en lugar de al procesador Z80. En este capítulo también repasaremos el listado completo de directivas soportadas.

Un aspecto importante y común a los cuatro elementos es que ABASM no discrimina entre mayúsculas y minúsculas. Por lo tanto, 'LD A,32' y 'ld a,32' producen el mismo resultado. Lo mismo se aplica a las etiquetas: 'main', 'MAIN' o 'Main' se consideran la misma etiqueta.

```
; Imprime todos los caracteres ASCII entre el código 32 y 128.
; Es una variación del primer ejemplo presentado en el
; manual de MAXAM

main              ; define la etiqueta global 'main'
    ld a,32       ; primer código de letra ASCII en el acumulador

.loop             ; define la etiqueta local 'loop'
    call &BB5A    ; LLAMA a txt_output, la rutina de salida del firmware
    inc  a        ; pasa al siguiente carácter
    cp   128      ; ¿hemos terminado con todos?
    jr   c,.loop  ; no - regresa para procesar el siguiente

.end  
    jp   .end     ; bucle infinito usado como punto final del programa

```

Otro aspecto importante de ABASM es que permite usar el símbolo '.' al principio de las etiquetas para definir las que son locales y solo accesibles desde el archivo o módulo en el que son declaradas.

## Comentarios

Los comentarios en código ensamblador son anotaciones escritas por el programador que no serán interpretadas ni ejecutadas por la CPU. Su objetivo es proporcionar información adicional sobre el código para hacerlo más comprensible y mantenible.

Los comentarios son importantes en cualquier lenguaje de programación, pero en ensamblador adquieren una relevancia aún mayor, ya que debido al bajo nivel de abstracción del lenguaje, el código no suele ser fácil de interpretar. Por lo tanto, son cruciales para explicar su propósito y funcionamiento. Como norma general, se recomienda hacer uso de los comentarios para:

- Describir partes complejas del código, explicando qué hace una secuencia particular de instrucciones o los parámetros y valores que devuelve una subrutina.
- Delimitar secciones del código, como bucles, funciones o bloques lógicos.
- Proporcionar contexto, indicando el propósito de una variable, etiqueta o constante.

En ABASM, los comentarios suelen indicarse con el carácter ';' (punto y coma). Cuando ABASM encuentra este carácter, procede a ignorar el resto de la línea.

```
; Esto es un comentario
; Esto es otro comentario
```

## Etiquetas

Las etiquetas en el código ensamblador son nombres simbólicos utilizados para marcar una posición específica en el programa, como una dirección de memoria o una instrucción. Sus principales usos son:

- En saltos y bucles: Las etiquetas se usan como destinos en instrucciones de salto (JMP, JE, etc.), permitiendo redirigir el flujo de ejecución a una parte específica del programa.

- En la definición de datos: Se utilizan para referirse a variables o datos en memoria, facilitando su acceso y manipulación.

- Como puntos de entrada a bloques de código: Ayudan a hacer el código más legible y fácil de mantener al proporcionar nombres descriptivos a secciones importantes del programa.

Todas las etiquetas son **globales** por defecto, lo que significa que deben ser únicas sin importar en cuántos archivos esté dividido el código fuente. ABASM ignora el carácter inicial '.' en la definición de etiquetas para admitir el formato de declaración de etiquetas de WinApe.  

Para crear una etiqueta local (restringida a un módulo/archivo o dentro de una macro), debe comenzar con el símbolo '!'. Si la etiqueta se define fuera de una macro, se considera una **etiqueta local del módulo**, accesible solo dentro del archivo donde se declara. Esto también evita que la etiqueta aparezca en el archivo de símbolos.  

Si la etiqueta se define dentro de una macro, se trata como una **etiqueta local de macro**. Las etiquetas locales de macro son esenciales para evitar errores causados por redefiniciones de etiquetas cuando la macro se invoca varias veces.  

```
!loop
  <algo de código>
  dec b
  jr z,!loop
```

## Instrucciones

Las instrucciones son operaciones que debe realizar la CPU (el procesador Z80 en nuestro caso). El proceso de ensamblar consiste en generar el código binario correspondiente a estas instrucciones. Cada instrucción suele estar compuesta por un *opcode* y sus *operandos*.

Un opcode (abreviatura de "operation code" o código de operación) es la parte de una instrucción que especifica la acción que debe realizar la CPU. Es un valor binario o hexadecimal único asociado a una operación particular, como sumar, restar, cargar un valor en un registro o realizar una comparación. Por lo tanto, el opcode determina la operación a ejecutar, mientras que los operandos (si los hay) proporcionan los datos necesarios para dicha operación. Por ejemplo:

```
ld a,32
```

El *opcode* (el nemotécnico asociado más bien) sería 'ld a', mientras que el operando sería '32'. El significado del opcode es 'cargar en el registro A', mientras que el valor a cargar sería directamente el número 32.

ABASM soporta todas las instrucciones estándar del Z80. Con la intención de mejorar la compatibilidad con la sintaxis de WinAPE, algunas instrucciones como AND, CP, OR y SUB aceptan incluir el registro A como parte del *opcode*. Sin embargo, se prefiere la forma abreviada sin el A explícito, y se emite un *warning* si se encuentra el formato extendido (por ejemplo, `CP A, &0A` es equivalente a `CP &0A` pero generará un *warning* durante el ensamblado).

A nivel de operandos, ABASM es totalmente compatible con los registros estándar de 8 bits del Z80: A, B, C, D, E, H y L, así como con los registros especiales de 8 bits I y R. También es compatible con todos los registros estándar de 16 bits del Z80: AF, BC, DE, HL y SP, junto con los registros de índice IX e IY. Además, ABASM ofrece soporte para el uso no documentado de las porciones de 8 bits de los registros IX e IY, permitiendo el uso de IXL, IXH, IYL e IYH. El registro alternativo AF' también se puede utilizar en las instrucciones adecuadas, como con la instrucción `EX AF, AF'`.

Por último, ABASM soporta las condiciones habituales NZ, Z, NC, C, PO, PE, P y M en las instrucciones diseñadas para tal fin, como, por ejemplo, las intrucciones de salto condicional.

Para consultar detalles específicos sobre cada instrucción del Z80 se pueden visitar las siguientes fuentes (en inglés):

- [@ClrHome Tabla de Instrucciones del Z80](https://clrhome.org/table/): Una tabla bien organizada que proporciona un resumen conciso de todas las instrucciones del Z80.
- [Documentación oficial de Zilog para el procesador Z80](https://www.zilog.com/docs/z80/um0080.pdf): Especialmente útiles son las dos últimas secciones tituladas *Z80 CPU Instructions* y *Z80 Instruction Set*.
- [Z80 Heaven](http://z80-heaven.wikidot.com/): Una web de referencia con información detallada de cada instrucción.
- [Tiempos del Z80 en Amstrad CPC - Hoja de trucos](https://www.cpcwiki.eu/imgs/b/b4/Z80_CPC_Timings_cheat_sheet.20230709.pdf): Este documento es invaluable para comprender el costo real en tiempo de todas las instrucciones del Z80. Aunque muchas fuentes enumeran los tiempos de las instrucciones en ciclos o estados T, el Amstrad CPC tiene su propia temporización debido a que el Gate Array pausa el procesador Z80 para acceder a la memoria de video. Por lo tanto, es más preciso medir el tiempo de cualquier instrucción en el Amstrad CPC en función del costo de la instrucción NOP.

En español, se pueden consultar los siguientes enlaces:

- [Resumen sobre el procesador Z80](https://ia801404.us.archive.org/7/items/z80-cpu-manual/ES%20-%20Z80%20CPU%20Manual.pdf): Un documento de 19 páginas con un buen resumen del procesador Z80 y su juego de instrucciones.
- [Juego de instrucciones del microprocesador Z80](https://www.infor.uva.es/~bastida/OC/Tablas%20Z80%20SPARC%20y%20ASCII.pdf): Otro buen documento centrado en las instrucciones soportadas por el procesador Z80.
- [Dominando el ensamblador Z80 (DEZ80) de la Universidad de Alicante](https://www.cpcwiki.eu/index.php/DEZ80): Serie de librosCurso de programación en ensamblador para el Amstrad CPC impartido por el profesor Francisco Gallego y en formato de vídeos.

## Directivas del Ensamblador

Una directiva en ensamblador es una instrucción que no se traduce directamente en código máquina para la CPU, sino que proporciona información o instrucciones al ensamblador sobre cómo procesar el código fuente. Estas directivas controlan aspectos del proceso de ensamblado, como la organización del código, la definición de datos, la asignación de memoria y la definición de constantes. A diferencia de las instrucciones que se ejecutan en la CPU, las directivas solo afectan al ensamblador durante el ensamblado del código fuente. Ejemplos comunes incluyen ORG (para establecer la dirección de inicio), EQU (para definir constantes) o DB (para definir datos en memoria). A continuación, se presenta una lista completa de las directivas soportadas por ABASM y su significado:

### ALIGN

- ALIGN n [,v]

*n* debe ser un número o una expresión numérica que sea una potencia de dos. Esta directiva añade los bytes necesarios para que la memoria utilizada hasta ese momento por el programa sea un múltiplo de *n*. El segundo parámetro opcional establece el valor con el que debe rellenarse la memoria necesaria (un valor entre 0 y 255). Si no se especifica este segundo argumento, la memoria se rellena con ceros.

Por ejemplo:

```
main:
    LD A, 0xFF
    ALIGN 8
data:
    DB 0xAA, 0xBB, 0xCC
```

Esto producirá el siguiente código binario:

```
3E FF 00 00 00 00 00 00 AA BB CC
```

### ASSERT

- ASSERT condición

Esta directiva evalúa si la condición proporcionada se cumple. Si no es así, aborta el proceso de ensamblado. Por ejemplo, el siguiente código verifica que la siguiente instrucción a ensamblar no ocupe una posición de memoria superior al inicio de la memoria de video (0xC000 en el Amstrad CPC).

```
ASSERT @<0xC000
```

### DB, DM, DEFB, DEFM 

- DEFB  n [,n ...]
- DEFM  n [,n ...]
- DB    n [,n ...]
- DM    n [,n ...]

Almacena en la posición actual de memoria la lista de bytes proporcionada como parámetro. *n* puede ser un número o una expresión numérica en el rango de 0 a 255 (0x00 a 0xFF).

```
DB 0xFF, 0xFF, 0xFF, 0xFF
```

También es posible usar una cadena de texto como parámetro y combinarla con el formato anterior. En este caso, se almacenarán los códigos ASCII de cada letra como si fueran los valores numéricos proporcionados.

```
DB "Hola Mundo",0x00
```

### DS, DEFS, RMEM

- DEFS  n
- DS    n
- RMEM  n

Reserva *n* bytes de memoria. Básicamente, la posición actual de memoria se incrementa en *n* bytes, dejándola libre para su uso posterior.

### DW, DEFW

- DEFW  n [,n ...]
- DW    n [,n ...]

Almacena *palabras* (dos bytes en formato little-endian) en la posición actual de memoria. *n* puede ser un número o una expresión numérica en el rango de 0 a 65535 (0x0000 a 0xFFFF).

```
year:
    DW  2024
```

### EQU

- EQU símbolo, valor
- símbolo EQU valor

Permite establecer el valor de un símbolo, normalmente utilizado como constante.

```
EQU MEM_VIDEO, 0xC000

LD  A,0xFF
LD  (MEM_VIDEO),A
```

### IF

- IF condición [ELSEIF condición | ELSE] ENDIF

La directiva IF permite que ciertas partes del código se incluyan o se ignoren, dependiendo del valor de una expresión lógica. Dicha expresión puede contener símbolos y valores numéricos. Si la expresión es verdadera (distinta de cero), el ensamblador procesará las líneas que siguen a la directiva IF. Si es falsa (igual a cero), esas líneas serán ignoradas.

Una estructura básica de IF podría ser:

```
IF expresión
    ; Código ensamblado si la expresión es verdadera
ELSE
    ; Código ensamblado si la expresión es falsa
ENDIF
```

Esta directiva es útil cuando se combina con la opción `--define` de ABASM, que permite cambiar qué código se ensambla dependiendo de la llamada hecha al ensamblador. Sin embargo, cualquier símbolo o constante referenciada en la expresión lógica debe haberse declarado previamente.

### INCBIN

- INCBIN "fichero binario"

Esta directiva inserta el contenido del fichero especificado entre comillas dobles. La ruta del fichero debe ser relativa a la ubicación del fichero que lo incluye.

```
INCBIN "./assets/mysprite.bin"
```

### MACRO

- MACRO símbolo [param1, param2, ...] ENDM

Esta directiva permite asignar un nombre o símbolo a un bloque de código que se extiende hasta la siguiente ocurrencia de ENDM. La macro puede incluir una lista de parámetros que serán sustituidos por los valores proporcionados en futuras *llamadas* a la macro. Una vez definida, una macro puede utilizarse en el resto del código como si fuera una instrucción convencional. Los parámetros se buscan en el código de la macro y se sustituyen por los valores pasados en la *llamada*. Por ese motivo, puede ser una buena práctica comenzar y finalizar cada nombre de parámetro con el carácter '_'; evitando, de ese modo, coincidencias accidentales con otras cadenas de texto o con nombres de registros o directivas.

```
macro get_screenPtr _REG_, _X_, _Y_ 
   ld _REG_, &C000 + 80 * (_Y_ / 8) + 2048 * (_Y_ & 7) + _X_ 
endm

main:
   get_screenPtr hl, 20, 10
``` 

El código de una macro puede contener *llamadas* a otras macros, pero no es posible definir una nueva macro ni utilizar la directiva **READ**. Si una macro contiene una etiqueta normal (global o local al módulo) y se *llama* más de una vez, el ensamblador detectará una redefinición de la etiqueta, lo que provocará un error. Si una macro necesita emplear etiquetas en su código, estas deben ir precedidas del símbolo '!', lo que las identificará como **etiquetas locales a la macro**.

```
macro decnz_a
  or a
  jr z,!leave
  dec a
  !leave
mend
```

### LET

- LET símbolo=valor

Esta directiva permite cambiar el valor de un símbolo o constante. Este símbolo o constante debe haber sido definido inicialmente con LET.

```
LET PADDING=0x00
<código>
LET PADDING=0xFF
<más código>
```

### LIMIT

- LIMIT dirección_de_memoria

Establece la dirección máxima de memoria que puede alcanzar el programa ensamblado. El valor suministrado puede ser un número o una expresión numérica. Por defecto, este valor es 65536 (64K).

```
LIMIT &C000   ; protegemos la memoria de video que empieza en &C000
ORG &C000
LD A,&FF      ; esta linea causará un error
```

### READ

- READ "fichero de código fuente"

Esta directiva inserta el contenido del fichero especificado entre comillas dobles y lo ensambla. La ruta del fichero debe ser relativa a la ubicación del fichero que lo incluye. Todos los símbolos definidos en el fichero insertado son globales, por lo que deben ser únicos y no repetirse en el fichero principal ni en ningún otro fichero incluido mediante este método.

```
READ "./lib/keyboard.asm"
```

### REPEAT

- REPEAT expresión numérica `bloque de código` REND

Repite un bloque de código tantas veces como el valor indicado por la expresión numérica.

```
EQU ENTITIES, 10
LET ENTITY_ID = 0
REPEAT ENTITIES
  DB 0x00       ; X pos
  DB 0x00       ; Y pos
  DB ENTITY_ID  ; Entity ID
  LET ENTITY_ID = ENTITY_ID + 1
REND
```

### ORG

- ORG dirección_de_memoria

Especifica la dirección de memoria que debe considerarse como la actual a partir de ese momento para cualquier cálculo necesario, como establecer el valor de una etiqueta. Lo habitual es que esta directiva aparezca como la primera instrucción del código fuente, aunque puede substituirse por la opción de ABASM `--start`.

```
ORG 0x4000
```

Nada impide incluir más de una ocurrencia de esta directiva en el código fuente, aunque hay que tener presente que cualquier zona de memoria "vacia" que quede entre la dirección de memoria inicial del programa y la dirección más alta será rellenada con 0, aumentando el tamaño del fichero `bin` resultante. Para evitarlo, si un programa necesita tener partes cargadas en diferentes áreas de la memoria, es aconsejable generar un fichero binario independiente para cada área y empaquetarlos todos dentro del mismo DSK o CDT, junto con un cargador programado en BASIC (por ejemplo).

### PRINT

- PRINT expresión[, expresión ...]

Imprime el resultado de la(s) expresión(es) proporcionada(s) en la salida estándar tan pronto como se evalúe durante el ensamblado. Esto puede ser útil para generar información adicional durante el ensamblado, como la memoria total que consume el programa.

```
ORG 0x4000
<código>
PRINT @-0x4000
```
### SAVE

- SAVE "fichero", expresión numérica, expresion numérica

Esta directiva permite generar archivos binarios adicionales con el contenido de la memoria en la que se está escribiendo el código ensamblado. La memoria tiene un tamaño máximo de 64K, que corresponde al límite del Amstrad CPC 464. La primera expresión define la dirección de inicio, mientras que la segunda especifica la cantidad total de bytes que se escribirán en el archivo.

```
SAVE "myscreen.bin",&C000,&4000
```

### STOP

- STOP

Detiene inmediatamente el proceso de ensamblado mostrando un error.

### WHILE

- WHILE expresión lógica `bloque de código` WEND

Permite ensamblar repetidamente un bloque de código mientras se cumpla la condición especificada. Si la condición nunca llega a ser falsa, esta directiva puede generar un bucle infinito.

```
LET OBJECTS = 32
WHILE OBJECTS>0
  db 0
  db 0
  db 0
  LET OBJECTS = OBJECTS-1
WEND
```

## Expresiones y Caracteres Especiales

Cuando una instrucción o directiva requiere un número como parámetro, se puede usar una expresión matemática en su lugar. Estas expresiones pueden hacer referencia a cualquier símbolo definido en el código. Si el resultado de una expresión es negativo, se utiliza su complemento a dos como valor. Además, algunos símbolos tienen significados especiales, que se detallan a continuación:

- **$** representa la dirección de memoria de la instrucción actual.
- **@** es intercambiable con el símbolo **$**.
- El prefijo **&** indica números en formato hexadecimal (por ejemplo, &FF).
- El prefijo **#** indica números en formato hexadecimal (por ejemplo, #FF).
- El prefijo **0x** también indica números en formato hexadecimal (por ejemplo, 0xFF).
- El prefijo **%** indica números en formato binario (por ejemplo, %11111111).
- El prefijo **0b** también indica números en formato binario (por ejemplo, 0b11111111).
- Las comillas dobles **"** delimitan caracteres o cadenas de texto (1).
- Las comillas simples **'** son equivalentes a las dobles para delimitar cadenas de texto.
- **MOD** es el operador módulo: op1 MOD op2.
- **AND** es el operador bit a bit AND: op1 AND op2. También se puede usar el operador & de Python.
- **OR** es el operador bit a bit OR: op1 OR op2. También se puede usar el operador | de Python.
- **XOR** es el operador bit a bit XOR: op1 XOR op2. También se puede usar el operador ^ de Python.
- **<<** es el operador *desplazamiento* a la izquierda.
- **>>** es el operador *desplazamiento* a la derecha.
  
(1) Un único carácter entre comillas dobles puede usarse para representar el valor ASCII de ese carácter en expresiones numéricas. Ni las comillas dobles ni las simples pueden aparecer dentro de una cadena de texto.

# Historial de cambios

- Versión 1.1 - ??/??/????
  * Soporte para la directiva LIMIT.
  * Soporte de etiquetas locales dentro del código de las macros.
  * Añadido el flag --verbose como opción al ensamblador.
  * Otros pequeños arreglos y mejoras.

- Versión 1.0 - 03/10/2024
  * Primera versión liberada.
