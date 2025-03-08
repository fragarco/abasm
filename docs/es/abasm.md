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
- [Conjunto de instrucciones del Z80](#conjunto-de-instrucciones-del-z80)
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

Para consultar los detalles específicos sobre cada instrucción, se puede recurrir a la lista incluida en la sección `Conjunto de instrucciones del Z80` o a los siguientes sitios web (en inglés):

- [@ClrHome Tabla de Instrucciones del Z80](https://clrhome.org/table/): Una tabla bien organizada que proporciona un resumen conciso de todas las instrucciones del Z80.
- [Documentación oficial de Zilog para el procesador Z80](https://www.zilog.com/docs/z80/um0080.pdf): Especialmente útiles son las dos últimas secciones tituladas *Z80 CPU Instructions* y *Z80 Instruction Set*.
- [Z80 Heaven](http://z80-heaven.wikidot.com/): Una web de referencia con información detallada de cada instrucción.

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

# Conjunto de instrucciones del Z80

Esta sección proporciona una lista breve de todas las instrucciones soportadas del Z80. Lo habitual en muchos otros lugares es indicar los tiempos de ejecución en ciclos o *T-states*. Sin embargo, el Amstrad CPC tiene su propia temporización debido a que el Gate Array pausa el Z80 para acceder a la memoria de video. Por lo tanto, es más preciso medir los tiempos de ejecución en función del coste de la instrucción NOP (1 microsegundo). Los tiempos de cada instrucción también se pueden consultar en la siguiente página web:

- [Tiempos del Z80 para el Amstrad CPC - Hoja de referencia rápida](https://www.cpcwiki.eu/imgs/b/b4/Z80_CPC_Timings_cheat_sheet.20230709.pdf)

**Key:**
```
r 	registro de 8-bits (B,C,D,E,H,L,A)
n 	valor numérico de 8-bits (0-255)
d 	desplazamiento de 8-bits (0-255)

rr 	registro de 16-bits (HL,DE,BC)
nn 	valor numérico de 16-bits (0-65.535)
dd  desplazamiento de 16-bits

cc	código de condición (z,nz,c,nc,p,m,po,pe)
nc 	condición no cumplida
c 	condición cumplida

b   posición de un bit (7-0)
```

```
opcode    timing    explicación

ADC   A,r       1 Suma con acarreo el registro r al acumulador.
ADC   A,n       2 Suma con acarreo el valor n al acumulador.
ADC   A,IXH     2 Suma con acarreo el byte alto de IX al acumulador.
ADC   A,IXL     2 Suma con acarreo el byte bajo de IX al acumulador.
ADC   A,IYH     2 Suma con acarreo el byte alto de IY al acumulador.
ADC   A,IYL     2 Suma con acarreo el byte bajo de IY al acumulador.
ADC   A,(HL)    2 Suma con acarreo la ubicación (HL) al acumulador.
ADC   A,(IX+d)  5 Suma con acarreo la ubicación (IX+d) al acumulador.
ADC   A,(IY+d)  5 Suma con acarreo la ubicación (IY+d) al acumulador.

ADC   HL,BC     4 Suma con acarreo el par de registros BC a HL.
ADC   HL,DE     4 Suma con acarreo el par de registros DE a HL.
ADC   HL,HL     4 Suma con acarreo el par de registros HL a HL.
ADC   HL,SP     4 Suma con acarreo el par de registros SP a HL.

ADD   A,r       1 Suma el registro r al acumulador.
ADD   A,n       2 Suma el valor n al acumulador.
ADD   A,IXH     2 Suma el byte alto de IX al acumulador.
ADD   A,IXL     2 Suma el byte bajo de IX al acumulador.
ADD   A,IYH     2 Suma el byte alto de IY al acumulador.
ADD   A,IYL     2 Suma el byte bajo de IY al acumulador.
ADD   A,(HL)    2 Suma la ubicación (HL) al acumulador.
ADD   A,(IX+d)  5 Suma la ubicación (IX+d) al acumulador.
ADD   A,(IY+d)  5 Suma la ubicación (IY+d) al acumulador.

ADD   HL,BC     3 Suma el par de registros BC a HL.
ADD   HL,DE     3 Suma el par de registros DE a HL.
ADD   HL,HL     3 Suma el par de registros HL a HL.
ADD   HL,SP     3 Suma el par de registros SP a HL.

ADD   IX,BC     4 Suma el par de registros BC a IX.
ADD   IX,DE     4 Suma el par de registros DE a IX.
ADD   IX,IX     4 Suma el par de registros IX a IX.
ADD   IX,SP     4 Suma el par de registros SP a IX.

ADD   IY,BC     4 Suma el par de registros BC a IY.
ADD   IY,DE     4 Suma el par de registros DE a IY.
ADD   IY,IY     4 Suma el par de registros IY a IY.
ADD   IY,SP     4 Suma el par de registros SP a IY.

AND   r         1 AND lógico del registro r con el acumulador.
AND   n         2 AND lógico del valor n con el acumulador.
AND   IXH       2 AND lógico del byte alto de IX con el acumulador.
AND   IXL       2 AND lógico del byte bajo de IX con el acumulador.
AND   IYH       2 AND lógico del byte alto de IY con el acumulador.
AND   IYL       2 AND lógico del byte bajo de IY con el acumulador.
AND   (HL)      2 AND lógico del valor en la ubicación (HL) con el acumulador.
AND   (IX+d)    5 AND lógico del valor en la ubicación (IX+d) con el acumulador.
AND   (IY+d)    5 AND lógico del valor en la ubicación (IY+d) con el acumulador.

BIT   b,r       2 Prueba el bit b del registro r.
BIT   b,(HL)    3 Prueba el bit b de la ubicación (HL).
BIT   b,(IX+d)  6 Prueba el bit b de la ubicación (IX+d).
BIT   b,(IY+d)  6 Prueba el bit b de la ubicación (IY+d).

CALL  nn        5 Llama a la subrutina en la ubicación nn.
CALL  cc,nn   3/5 Llama a la subrutina en la ubicación nn si la condición CC es verdadera (5), de lo contrario (3).

CCF             1 Complementa el flag de acarreo.

CP    r         1 Compara el registro r con el acumulador.
CP    n         2 Compara el valor n con el acumulador.
CP    IXH       1 Compara el byte alto de IX con el acumulador.
CP    IXL       1 Compara el byte bajo de IX con el acumulador.
CP    IYH       1 Compara el byte alto de IY con el acumulador.
CP    IYL       1 Compara el byte bajo de IY con el acumulador.
CP    (HL)      2 Compara el valor en la ubicación (HL) con el acumulador.
CP    (IX+d)    5 Compara el valor en la ubicación (IX+d) con el acumulador.
CP    (IY+d)    5 Compara el valor en la ubicación (IY+d) con el acumulador.

CPD             5 Comparar la ubicación (HL) con el acumulador, decrementar HL y BC,
CPDR          5/6 Realizar un CPD y repetir hasta que BC=0 (5), si BC<>0 (6).
CPI             5 Comparar la ubicación (HL) con el acumulador, incrementar HL, decrementar BC.
CPIR          5/6 Realizar un CPI y repetir hasta que BC=0 (5), si BC<>0 (6).
CPL             1 Complementar el acumulador (complemento a 1).

DAA             1 Ajustar el acumulador a formato decimal.

DEC   r         1 Decrementar el registro r.
DEC   IXH       2 Decrementar el byte alto de IX.
DEC   IXL       2 Decrementar el byte bajo de IX.
DEC   IYH       2 Decrementar el byte alto de IY.
DEC   IYL       2 Decrementar el byte bajo de IY.
DEC   (HL)      3 Decrementar el valor en la ubicación (HL).
DEC   (IX+d)    6 Decrementar el valor en la ubicación (IX+d).
DEC   (IY+d)    6 Decrementar el valor en la ubicación (IY+d).

DEC   BC        2 Decrementar el par de registros BC.
DEC   DE        2 Decrementar el par de registros DE.
DEC   HL        2 Decrementar el par de registros HL.
DEC   IX        3 Decrementar IX.
DEC   IY        3 Decrementar IY.
DEC   SP        2 Decrementar el par de registros SP.

DI              1 Deshabilitar interrupciones. (excepto NMI en 0066h)

DJNZ  n       3/4 Decrementar B y saltar de manera relativa si B<>0 (4), si B=0 (3).

EI              1 Habilitar interrupciones.

EX    AF,AF'    1 Intercambiar el contenido de AF y AF'.
EX    DE,HL     1 Intercambiar el contenido de DE y HL.
EX    (SP),HL   6 Intercambiar la ubicación (SP) y HL.
EX    (SP),IX   7 Intercambiar la ubicación (SP) y IX.
EX    (SP),IY   7 Intercambiar la ubicación (SP) y IY.
EXX             1 Intercambiar el contenido de BC,DE,HL con BC',DE',HL'.

HALT          1/* Detener la computadora y esperar una interrupción (tiempo variable).

IM    0         2 Establecer el modo de interrupción 0. (instrucción en el bus de datos por el dispositivo de interrupción)
IM    1         2 Establecer el modo de interrupción 1. (rst 38)
IM    2         2 Establecer el modo de interrupción 2. (salto a vector)

IN    A,(n)     3 Cargar el acumulador con la entrada del dispositivo/puerto n.
IN    r,(C)     4 Cargar el registro r con la entrada del dispositivo/puerto almacenado en B(!!)[1].

INC   r         1 Incrementar el registro r.
INC   IXH       2 Incrementar el byte alto de IX.
INC   IXL       2 Incrementar el byte bajo de IX.
INC   IYH       2 Incrementar el byte alto de IY.
INC   IYL       2 Incrementar el byte bajo de IY.
INC   (HL)      3 Incrementar la ubicación (HL).
INC   (IX+d)    6 Incrementar la ubicación (IX+d).
INC   (IY+d)    6 Incrementar la ubicación (IY+d).

INC   BC        2 Incrementar el par de registros BC.
INC   DE        2 Incrementar el par de registros DE.
INC   HL        2 Incrementar el par de registros HL.
INC   IX        3 Incrementar IX.
INC   IY        3 Incrementar IY.
INC   SP        2 Incrementar el par de registros SP.

IND             5 (HL)=Entrada desde el puerto (C), Decrementar HL y B.
INDR          5/6 Realizar un IND y repetir hasta que B=0 (5), si B<>0 (6).
INI             5 (HL)=Entrada desde el puerto (C), HL=HL+1, B=B-1.
INIR          5/6 Realizar un INI y repetir hasta que B=0 (5), si B<>0 (6).

JP    nn        3 Salto incondicional a la ubicación nn.
JP    cc,nn     3 Salto a la ubicación nn si la condición cc es verdadera.
JP    (HL)      1 Salto incondicional a la ubicación (HL).
JP    (IX)      2 Salto incondicional a la ubicación (IX).
JP    (IY)      2 Salto incondicional a la ubicación (IY).

JR    c,n     2/3 Salto relativo a PC+n si carry=1 (3), si carry=0 (2).
JR    n         3 Salto incondicional relativo a PC+n.
JR    nc,n    2/3 Salto relativo a PC+n si carry=0 (3), si carry=0 (2).
JR    nz,n    2/3 Salto relativo a PC+n si no es cero (3), si es cero (2).
JR    z,n     2/3 Salto relativo a PC+n si es cero (3), si no es cero (2).

LD    A,R       3 Cargar el acumulador con R.(registro de refresco de memoria)
LD    A,I       3 Cargar el acumulador con I.(registro de vector de interrupción)
LD    A,(BC)    2 Cargar el acumulador con el valor en la ubicación (BC).
LD    A,(DE)    2 Cargar el acumulador con el valor en la ubicación (DE).
LD    A,(nn)    4 Cargar el acumulador con el valor en la ubicación nn.

LD    I,A       3 Cargar I con el acumulador.
LD    R,A       3 Cargar R con el acumulador.
LD    r,n       2 Cargar el registro r con el valor n.
LD    r,(HL)    2 Cargar el registro r con el valor en la ubicación (HL).
LD    r,(IX+d)  5 Cargar el registro r con el valor en la ubicación (IX+d).
LD    r,(IY+d)  5 Cargar el registro r con el valor en la ubicación (IY+d).

LD    SP,HL     2 Cargar SP con HL.
LD    SP,IX     3 Cargar SP con IX.
LD    SP,IY     3 Cargar SP con IY.

LD    BC,nn     3 Cargar el par de registros BC con nn.
LD    DE,nn     3 Cargar el par de registros DE con nn.
LD    HL,nn     3 Cargar el par de registros HL con nn.
LD    IX,nn     4 Cargar IX con el valor nn.
LD    IY,nn     4 Cargar IY con el valor nn.
LD    SP,nn     3 Cargar el par de registros SP con nn.
LD    BC,(nn)   6 Cargar el par de registros BC con el valor en la ubicación (nn).
LD    DE,(nn)   6 Cargar el par de registros DE con el valor en la ubicación (nn).
LD    HL,(nn)   5 Cargar HL con el valor en la ubicación (nn), primero L.
LD    IX,(nn)   6 Cargar IX con el valor en la ubicación (nn).
LD    IY,(nn)   6 Cargar IY con el valor en la ubicación (nn).
LD    SP,(nn)   6 Cargar el par de registros SP con el valor en la ubicación (nn).

LD    (BC),A    2 Cargar la ubicación (BC) con el acumulador.
LD    (DE),A    2 Cargar la ubicación (DE) con el acumulador.
LD    (HL),n    3 Cargar la ubicación (HL) con el valor n.
LD    (HL),r    2 Cargar la ubicación (HL) con el registro r.
LD    (IX+d),n  6 Cargar la ubicación (IX+d) con el valor n.
LD    (IX+d),r  5 Cargar la ubicación (IX+d) con el registro r.
LD    (IY+d),n  6 Cargar la ubicación (IY+d) con el valor n.
LD    (IY+d),r  5 Cargar la ubicación (IY+d) con el registro r.

LD    (nn),A    4 Cargar la ubicación (nn) con el acumulador.
LD    (nn),BC   6 Cargar la ubicación (nn) con el par de registros BC.
LD    (nn),DE   6 Cargar la ubicación (nn) con el par de registros DE.
LD    (nn),HL   5 Cargar la ubicación (nn) con HL.
LD    (nn),SP   6 Cargar la ubicación (nn) con el par de registros SP.
LD    (nn),IX   6 Cargar la ubicación (nn) con IX.
LD    (nn),IY   6 Cargar la ubicación (nn) con IY.

LDD             5 Cargar la ubicación (DE) con la ubicación (HL), decrementar DE, HL, BC.
LDDR          5/6 Realizar un LDD y repetir hasta que BC=0 (5), si BC<>0 (6).
LDI             5 Cargar la ubicación (DE) con la ubicación (HL), incrementar DE, HL; decrementar BC.
LDIR          5/6 Realizar un LDI y repetir hasta que BC=0 (5), si BC<>0 (6).

NEG             2 Negar el acumulador (complemento a 2).
NOP             1 Ninguna operación.

OR    r         1 OR lógico entre el registro r y el acumulador.
OR    n         2 OR lógico entre el valor n y el acumulador.
OR    IXH       2 OR lógico entre el byte alto de IX y el acumulador.
OR    IXL       2 OR lógico entre el byte bajo de IX y el acumulador.
OR    IYH       2 OR lógico entre el byte alto de IY y el acumulador.
OR    IYL       2 OR lógico entre el byte bajo de IY y el acumulador.
OR    (HL)      2 OR lógico entre el valor en la ubicación (HL) y el acumulador.
OR    (IX+d)    5 OR lógico entre el valor en la ubicación (IX+d) y el acumulador.
OR    (IY+d)    5 OR lógico entre el valor en la ubicación (IY+d) y el acumulador.

OTDR          5/6 Realizar un OUTD y repetir hasta que B=0 (5), si B<>0 (6)[1].
OTIR          5/6 Realizar un OTI y repetir hasta que B=0 (5), si B<>0 (6)[1].
OUT   (C),r     4 Cargar el puerto de salida almacenado en el registro B(!!) con el registro r[1].
OUT   (n),A     3 Cargar el puerto de salida (n) con el acumulador[1].
OUTD            5 Cargar el puerto de salida en el registro B(!!) con (HL), decrementar HL y B[1].
OUTI            5 Cargar el puerto de salida en el registro B(!!) con (HL), incrementar HL, decrementar B[1].

POP   AF        3 Cargar el par de registros AF con la parte superior de la pila.
POP   BC        3 Cargar el par de registros BC con la parte superior de la pila.
POP   DE        3 Cargar el par de registros DE con la parte superior de la pila.
POP   HL        3 Cargar el par de registros HL con la parte superior de la pila.
POP   IX        5 Cargar IX con la parte superior de la pila.
POP   IY        5 Cargar IY con la parte superior de la pila.
PUSH  AF        4 Cargar el par de registros AF en la pila.
PUSH  BC        4 Cargar el par de registros BC en la pila.
PUSH  DE        4 Cargar el par de registros DE en la pila.
PUSH  HL        4 Cargar el par de registros HL en la pila.
PUSH  IX        5 Cargar IX en la pila.
PUSH  IY        5 Cargar IY en la pila.

RES   b,r       2 Restablecer el bit b del registro r.
RES   b,(HL)    4 Restablecer el bit b en el valor en la ubicación (HL).
RES   b,(IX+d)  7 Restablecer el bit b en el valor en la ubicación (IX+d).
RES   b,(IY+d)  7 Restablecer el bit b en el valor en la ubicación (IY+d).

RET             3 Regresar de la subrutina.
RET   cc      2/4 Regresar de la subrutina si la condición cc es verdadera (4), si no (2).
RETI            4 Regresar de la interrupción.
RETN            4 Regresar de la interrupción no enmascarable.

RL    r         2 Rotar a la izquierda a través del registro r.
RL    (HL)      4 Rotar a la izquierda a través del valor en la ubicación (HL).
RL    (IX+d)    7 Rotar a la izquierda a través del valor en la ubicación (IX+d).
RL    (IY+d)    7 Rotar a la izquierda a través del valor en la ubicación (IY+d).
RLA             4 Rotar a la izquierda el acumulador a través del carry.

RLC   r         2 Rotar el registro r a la izquierda de manera circular.
RLC   (HL)      4 Rotar la ubicación (HL) a la izquierda de manera circular.
RLC   (IX+d)    7 Rotar la ubicación (IX+d) a la izquierda de manera circular.
RLC   (IY+d)    7 Rotar la ubicación (IY+d) a la izquierda de manera circular.

RLCA            1 Rotar a la izquierda de manera circular el acumulador.
RLD             5 Rotar el dígito a la izquierda y derecha entre el acumulador y (HL).

RR    r         2 Rotar a la derecha con el acarreo del registro r.
RR    (HL)      4 Rotar a la derecha con el acarreo en la ubicación (HL).
RR    (IX+d)    7 Rotar a la derecha con el acarreo en la ubicación (IX+d).
RR    (IY+d)    7 Rotar a la derecha con el acarreo en la ubicación (IY+d).

RRA             1 Rotar a la derecha el acumulador con el acarreo.

RRC   r         2 Rotar el registro r a la derecha de manera circular.
RRC   (HL)      4 Rotar la ubicación (HL) a la derecha de manera circular.
RRC   (IX+d)    7 Rotar la ubicación (IX+d) a la derecha de manera circular.
RRC   (IY+d)    7 Rotar la ubicación (IY+d) a la derecha de manera circular.

RRCA            1 Rotar el acumulador a la derecha de manera circular.
RRD             5 Rotar el dígito a la izquierda y derecha entre el acumulador y (HL).

RST   &00       4 RESET. Reservado [2]. Resetea el sistema.
RST   &08       4 SALTO BAJO. Reservado [2]. Salta a una rutina en los primeros 16K.
RST   &10       4 LLAMADA LATERAL. Reservado [2]. Llama a una rutina en un ROM asociado.
RST   &18       4 LLAMADA LEJANA. Reservado [2]. Llama a una rutina en cualquier lugar de la memoria.
RST   &20       4 RAM LAM. Reservado [2]. Lee el byte desde RAM en la dirección de HL.
RST   &28       4 SALTO FIRME. Reservado [2]. Salta a una rutina en el ROM inferior.
RST   &30       4 RST USUARIO. Disponible para que el usuario extienda el conjunto de instrucciones.
RST   &38       4 INTERRUPCIÓN. Reservado [2]. Reservado para interrupciones.

SBC   A,r       1 Resta el registro r del acumulador con acarreo.
SBC   A,n       2 Resta el valor n del acumulador con acarreo.
ADC   A,IXH     2 Resta el byte alto de IX del acumulador con acarreo.
ADC   A,IXL     2 Resta el byte bajo de IX del acumulador con acarreo.
ADC   A,IYH     2 Resta el byte alto de IY del acumulador con acarreo.
ADC   A,IYL     2 Resta el byte bajo de IY del acumulador con acarreo.
SBC   A,(HL)    2 Resta el valor en la ubicación (HL) del acumulador con acarreo.
SBC   A,(IX+d)  5 Resta el valor en la ubicación (IX+d) del acumulador con acarreo.
SBC   A,(IY+d)  5 Resta el valor en la ubicación (IY+d) del acumulador con acarreo.
SBC   HL,BC     4 Resta el par de registros BC de HL con acarreo.
SBC   HL,DE     4 Resta el par de registros DE de HL con acarreo.
SBC   HL,HL     4 Resta el par de registros HL de HL con acarreo.
SBC   HL,SP     4 Resta el par de registros SP de HL con acarreo.

SCF             1 Establecer la bandera de acarreo (C=1).

SET   b,r       2 Establecer el bit b del registro r.
SET   b,(HL)    4 Establecer el bit b en el valor de la ubicación (HL).
SET   b,(IX+d)  7 Establecer el bit b en el valor de la ubicación (IX+d).
SET   b,(IY+d)  7 Establecer el bit b en el valor de la ubicación (IY+d).

SLA   r         2 Desplazar el registro r a la izquierda de manera aritmética.
SLA   (HL)      4 Desplazar el valor en la ubicación (HL) a la izquierda de manera aritmética.
SLA   (IX+d)    7 Desplazar el valor en la ubicación (IX+d) a la izquierda de manera aritmética.
SLA   (IY+d)    7 Desplazar el valor en la ubicación (IY+d) a la izquierda de manera aritmética.

SLL   r         2 Desplazar el registro r a la izquierda de manera lógica.
SLL   (HL)      4 Desplazar el valor en la ubicación (HL) a la izquierda de manera lógica.
SLL   (IX+d)    7 Desplazar el valor en la ubicación (IX+d) a la izquierda de manera lógica.
SLL   (IY+d)    7 Desplazar el valor en la ubicación (IY+d) a la izquierda de manera lógica.

SRA   r         2 Desplazar el registro r a la derecha de manera aritmética.
SRA   (HL)      4 Desplazar el valor en la ubicación (HL) a la derecha de manera aritmética.
SRA   (IX+d)    7 Desplazar el valor en la ubicación (IX+d) a la derecha de manera aritmética.
SRA   (IY+d)    7 Desplazar el valor en la ubicación (IY+d) a la derecha de manera aritmética.

SRL   r         2 Desplazar el registro r a la derecha de manera lógica.
SRL   (HL)      4 Desplazar el valor en la ubicación (HL) a la derecha de manera lógica.
SRL   (IX+d)    7 Desplazar el valor en la ubicación (IX+d) a la derecha de manera lógica.
SRL   (IY+d)    7 Desplazar el valor en la ubicación (IY+d) a la derecha de manera lógica.

SUB   r         1 Restar el registro r del acumulador.
SUB   n         2 Restar el valor n del acumulador.
SUB   IXH       2 Restar el byte alto de IX del acumulador.
SUB   IXL       2 Restar el byte bajo de IX del acumulador.
SUB   IYH       2 Restar el byte alto de IY del acumulador.
SUB   IYL       2 Restar el byte bajo de IY del acumulador.
SUB   (HL)      2 Restar el valor en la ubicación (HL) del acumulador.
SUB   (IX+d)    5 Restar el valor en la ubicación (IX+d) del acumulador.
SUB   (IY+d)    5 Restar el valor en la ubicación (IY+d) del acumulador.

XOR   r         1 Realizar una OR exclusiva entre el registro r y el acumulador.
XOR   n         2 Realizar una OR exclusiva entre el valor n y el acumulador.
XOR   IXH       2 Realizar una OR exclusiva entre el byte alto de IX y el acumulador.
XOR   IXL       2 Realizar una OR exclusiva entre el byte bajo de IX y el acumulador.
XOR   IYH       2 Realizar una OR exclusiva entre el byte alto de IY y el acumulador.
XOR   IYL       2 Realizar una OR exclusiva entre el byte bajo de IY y el acumulador.
XOR   (HL)      2 Realizar una OR exclusiva entre el valor en la ubicación (HL) y el acumulador.
XOR   (IX+d)    5 Realizar una OR exclusiva entre el valor en la ubicación (IX+d) y el acumulador.
XOR   (IY+d)    5 Realizar una OR exclusiva entre el valor en la ubicación (IY+d) y el acumulador.
```

**[1]** Es importante recordar que las instrucciones de la familia OUT/IN utilizan el contenido de `BC` y no solo `C`, incluso si el código de operación es `OUT (C)`. En el Amstrad CPC, las instrucciones OUTD, OUTI, OTIR, etc., no tienen mucho sentido porque el AMSTRAD CPC utiliza el valor de `B`(!!) del registro doble `BC` para indicar el número del puerto y no `C`, como hacen muchas otras máquinas basadas en el Z80.

**[2]** Todas las instrucciones RST del Z80, excepto una, han sido reservadas para uso del sistema. De RST 1 a RST 5 (&08-&28) se utilizan para extender el conjunto de instrucciones añadiendo instrucciones específicas de llamada y salto que habilitan y deshabilitan los ROMs. RST 6 (&30) está disponible para el usuario. Se puede obtener más información sobre el uso de la instrucción RST aquí: [ROMs. RAM and Restart Instructions.](https://www.cpcwiki.eu/imgs/f/f6/S968se02.pdf)

# Historial de cambios

- Versión 1.1.1 - ??/??/????
   * 

- Versión 1.1.0 - 06/03/2025
  * Soporte para la directiva LIMIT.
  * Soporte de etiquetas locales dentro del código de las macros.
  * Añadido el flag --verbose como opción al ensamblador.
  * Añadidos tests ejecutables mediante python -m unittest
  * Otros pequeños arreglos y mejoras.

- Versión 1.0.0 - 03/10/2024
  * Primera versión liberada.
