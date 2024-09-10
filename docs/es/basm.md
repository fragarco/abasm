# Introducción

BASM es un ensamblador cruzado diseñado específicamente para la plataforma Amstrad CPC y su CPU Z80. Desarrollado en Python 3, su principal objetivo es proporcionar una herramienta ligera y altamente portable para programadores interesados en crear código ensamblador para esta clásica plataforma de 8 bits. Al no depender de librerías externas ni herramientas de terceros, BASM puede ejecutarse en cualquier sistema que cuente con un intérprete de Python 3. Además, el proyecto incluye otras herramientas, también programadas en Python y sin dependencias, para empaquetar el resultado del ensamblador en archivos DSK o CDT.

BASM está basado en el fantástico proyecto pyZ80, creado inicialmente por Andrew Collier y modificado posteriormente por Simon Owen.

## ¿Por qué otro ensamblador para Amstrad?

BASM surge de la idea de contar con una herramienta portable y fácil de modificar por cualquiera, sin depender de sistemas operativos específicos o entornos de desarrollo particulares. Uno de sus objetivos es proporcionar una sintaxis compatible con el antiguo ensamblador MAXAM, con la sintaxis de WinAPE y con la de Virtual Machine Simulator. De esta forma, los desarrolladores pueden contar con varias opciones para depurar su código durante el desarrollo.

En cualquier caso, si lo que buscas es eficiencia en vez de portabilidad y facilidad de modificación, quizás quieras probar estos otros ensambladores:

* [Pasmo](https://pasmo.speccy.org/)
* [ASZ80](https://shop-pdp.net/ashtml/)
* [Rasm](https://github.com/EdouardBERGE/rasm)

# Cómo se usa

Para ensamblar un archivo fuente de código en ensamblador (por ejemplo, `program.asm`), basta con ejecutar el siguiente comando:

```
python3 basm.py <program.asm> [opciones]
```

Este comando ensamblará el archivo `program.asm` y generará un fichero binario con el mismo nombre, `program.bin`.

## Opciones disponibles

- `-d` o `--define`: Permite definir pares `SÍMBOLO=VALOR`. Dichos símbolos pueden utilizarse en el código como constantes o etiquetas. Esta opción se puede emplear múltiples veces para definir varios símbolos.
- `--start`: Define la dirección de memoria que se tomará como punto de inicio para la carga del programa. Por defecto, esta dirección es `0x4000`, aunque también puede establecerse directamente dentro del código usando la directiva `ORG`.
- `-o` o `--output`: Especifica el nombre del archivo binario de salida. Si no se utiliza esta opción, se empleará el nombre del archivo de entrada cambiando su extensión por `.bin`.

## Ejemplos de uso

Definir una constante utilizada en el código:

```
python3 basm.py program.asm -d MY_CONSTANT=100
```

Establecer el nombre exacto del archivo binario ensamblado:

```
python3 basm.py program.asm -o output.bin
```

Establecer la dirección de inicio en memoria que debe considerarse para el cálculo de los saltos y otras referencias relativas utilizadas en el código fuente, por ejemplo, a `0x2000`:

```
python3 basm.py program.asm --start 0x2000
```

# Productos del ensamblado

Una ejecución con éxito de BASM genera varios ficheros. En esta sección se proporciona una somera explicación de cada uno de dichos productos.

## El fichero binario

El resultado último del proceso de ensablado es un fichero binario (normalmente con la extensión BIN) listo para su carga en memoria y su ejecución en un Amstrad CPC. El código fuente puede dividirse en varios ficheros, pero solo uno, el principal, se pasa como parámetro a BASM para iniciar el ensamblado. El resto de ficheros serán añadidos según sean referenciados por las directivas READ o INCBIN.

BASM no genera código relocalizable (relocatable), lo que significa que asume una dirección de memoria inicial de carga. Esta dirección de carga puede indicarse como parámetro en la llamada a BASM o puede establecerse en el propio fichero principal mediante la directiva ORG.

Por ejemplo, el siguiente código en esamblador que carga el valor 0xFF en la primera posición de la memoria de vídeo generaría el contenido binario que se muestra posteriormente (como secuencia de valores en hexadecimal).

```
org  0x4000       ; Fijamos la dirección inicial de carga en memoria

main:
    ld   a,0xFF       ; Cargamos en el acumulador el valor 0xFF
    ld   (0xC000),a   ; Cargamos en el primer byte de la memoria 
                      ; de vídeo el contenido de A
endloop:              ; Bucle infinito de fin
    jp endloop        ; El valor de 'endloop' se calculará 
                      ; según el valor inicial indicado por ORG
```

```
3E FF 32 00 C0 C3 05 40
```

Considerando que el Z80 es *little-endian*, vemos que los últimos tres bytes son C3 05 40, lo que equivale a C3 4005 que es el resultado en código máquina para 'jp endloop' con 'endloop' calculado a partir de la dirección de inicio 0x4000.

## Listado del programa

Como referencia para el programador, el proceso de ensablado también genera un fichero con el listado del programa original y el resultado en binario de cada una de las instrucciones. La extensión de este fichero es LST.

Siguiendo con el ejemplo proporcionado en el punto anterior, el fichero LST generado tendría el siguiente contenido:

```
000001  4000               	org  0x4000
000002  4000               	main
000003  4000  3E FF        	ld   a, 0xFF
000004  4002  32 00 C0     	ld  (0xC000), a
000005  4005               	endloop
000006  4005  C3 05 40     	jp endloop
```

La primera columna indica el número secuencial de la instrucción en el fichero de código fuente. La segunda columna indica que posición de memoria debe ocupar el código generado (si se generó alguno, ya que algunas directivas y las etiquetas no generan código binario). La tercera columna muestra el código binario resultado de ensamblar la instrucción y la última columna la instrucción original.

## Fichero de símbolos

BASM también genera un listado de todos los símbolos encontrados y su valor asociado. La mayoría de ellos serán las etiquetas utilizadas para marcar posiciones de salto o lugares de la memoria donde se han almacenado determinados datos.

La extensión de este fichero es MAP y su formato es el de un diccionario de Python. Esto permite emplear el fichero desde otras utilidades (como los empaquetadores DSK y CDT) y utilizar los símbolos en vez de sus valores. En la documentación sobre las utilidades DSK y CDT se puede encontrar un ejemplo de uso de este fichero.

```
# List of symbols in Python dictionary format
# Symbol: [address, total number of appearances]
{
	"ENDLOOP": [0x4005, 2],
	"MAIN": [0x4000, 1],
}
```

# Sintaxis

La sintaxis de BASM trata de asemejarle lo máximo posible a la del ensamblador MAXAM. Dicha sintaxis es bastante compatible con la soportada por el simulador WinAPE. Además, BASM soporta algunas variaciones que también lo hacen compatible con la sintaxis utilizada por el simulador Retro Virtual Machine. El objetivo de esto es permitir que los desarrolladores que usen BASM dispongan de varias herramientas para la depuración y prueba de sus programas.

A continuación, se muestra un ejemplo sencillo de programa escrito empleando la sintaxis de BASM. Dicho ejemplo muestra tres de los elementos básicos de cualquier programa escrito en ensamblador: etiquetas, instrucciones y comentarios. Un cuarto elemento serían las directivas del ensamblador, comandos dirigidos al propio BASM antes que al procesador Z80. En este capítulo también repasaremos el listado completo de directivas soportadas.

Un aspecto importante y común a los cuatro elementos es que BASM no discrimina entre mayúsculas y minúsculas. Por tanto, 'LD A,32' y 'ld a,32' producen el mismo resultado. Lo mismo se aplica a las etiquetas: 'main', 'MAIN' o 'Main' sse consideran la misma etiqueta.

```
; Prints all ASCII characters between code 32 and 128.
; It's a variation of the first example presented in the
; MAXAM manual

.main             ; defines a label 'main'
    ld a,32       ; first ASCII letter code in accumulator

.loop             ; define a label 'loop'
    call &BB5A    ; CALL txt_output, the firmware output routine
    inc  a        ; move to next character
    cp   128      ; have we done them all?
    jr   c,loop   ; no - go back for another one

.end  
    jp   end      ; infinite loop used as the program's end point

```

Otro aspecto importante es que BASM ignora el símbolo '.' al principio de cualquier etiqueta, directiva o instrucción. Una vez más, el objetivo es soportar el mayor número posible de dialectos de ensamblador. De esta forma, .MAIN o MAIN serían la misma etiqueta, mientras que la directiva ORG 0x4000 también puede escribirse como .ORG 0x4000.

## Comentarios

Los comentarios en código ensamblador son anotaciones escritas por el programador que no serán interpretadas ni ejecutadas por la CPU. Su objetivo es proporcionar información adicional sobre el código para hacerlo más comprensible y mantenible.

Los comentarios son importantes en cualquier lenguaje de programación, pero en ensamblador adquieren una importancia aún mayor, ya que debido al bajo nivel de abstracción del lenguaje, el código no suele ser sencillo de interpretar. Por tanto, son cruciales para explicar su propósito y funcionamiento. Como norma general, se recomienda hacer uso de los comentarios para:

- Describir partes del código complejas, explicando qué hace una secuencia de instrucciones particular o los parámetros y valor que devuelve una subrutina.
- Delimitar secciones del código, como bucles, funciones o bloques lógicos.
- Proporcionar contexto, indicando el propósito de una variable, etiqueta o constante.

En BASM, los comentarios suelen indicarse con el caracter ';' (punto y coma). Cuando BASM encuentra dicho caracter, procede a ignorar el resto de la línea.

```
; Esto es un comentario
; Esto es otro comentario
```

## Etiquetas

Las etiquetas en el código ensamblador son nombres simbólicos que se utilizan para marcar una posición específica en el programa, como una dirección de memoria o una instrucción. Sus principales usos serían:

- En saltos y bucles: Las etiquetas se usan como destinos en instrucciones de salto (JMP, JE, etc.), permitiendo redirigir el flujo de ejecución a una parte específica del programa.

- En la definición de datos: Se utilizan para referirse a variables o datos en memoria, facilitando su acceso y manipulación.

- Como entrada a bloques de código: Ayudan a hacer el código más legible y fácil de mantener al dar nombres descriptivos a secciones importantes del programa.

## Instrucciones

Las instrucciones son operaciones que debe realizar la CPU (el procesador Z80 en nuestro caso). El proceso de ensamblar consiste en generar el código binario correspondiente a dichas instrucciones. Cada instrucción suele estar compuesta por un *opcode* y sus *operandos*.

Un opcode (abreviatura de operation code o código de operación) es la parte de una instrucción que especifica la acción que debe realizar la CPU. Es un valor binario o hexadecimal único asociado a una operación particular, como sumar, restar, cargar un valor en un registro o realizar una comparación. Por tanto, el opcode determina la operación a ejecutar, mientras que los operandos (si los hay) proporcionan los datos necesarios para dicha operación. Por ejemplo:

```
ld a,32
```

El *opcode* sería 'ld a' mientras que el operando sería '32'. El significado del opcode es 'carga en el registro A', mientras que el valor a cargar sería directamente el número 32.

La explicación de todos los opcodes soportados por el procesador Z80 queda fuera del alcance de este manual. Sin embargo, el lector interesado puede consultar cualquiera de los siguientes recursos:

- [Tabla resumen de los opcodes soportados por el Z80](https://clrhome.org/table)
- [Z80 Heaven](http://z80-heaven.wikidot.com/)
- [Manual oficial del Z80](https://www.zilog.com/docs/z80/um0080.pdf)

## Directivas del ensamblador

Una directiva en ensamblador es una instrucción que no se traduce directamente en código máquina para la CPU, sino que proporciona información o instrucciones al ensamblador sobre cómo procesar el código fuente. Estas directivas controlan aspectos del proceso de ensamblado, como la organización del código, la definición de datos, la asignación de memoria y la definición de constantes. A diferencia de las instrucciones que se ejecutan en la CPU, las directivas solo afectan al ensamblador durante el ensamblado del código fuente. Ejemplos comunes incluyen ORG (para establecer la dirección de inicio), EQU (para definir constantes) o DB (para definir datos en memoria). La lista completa de directivas soportadas por BASM y su significado es el siguiente:

### ALIGN

- ALIGN n [,v]

*n* debe ser un número o expresión numérica potencia de dos. Esta directiva añade los bytes necesarios para que la memoria consumida hasta ese momento por el programa sea múltiplo de *n*. El segundo parámetro opcional establece el valor con el que debe rellenarse la memoria necesaria (un valor entre 0 y 255). Si no se especifica este segundo argumento, la memoria se rellena con ceros.

Por ejemplo:

```
main:
    LD A, 0xFF
    ALIGN 8
data:
    DB 0xAA, 0xBB, 0xCC
```

Producirá el siguiente código binario:

```
3E FF 00 00 00 00 00 00 AA BB CC
```

### ASSERT

- ASSERT condición

Esta directiva evalua si la condición suministrada se cumple. Si no es así, aborta el proceso de ensamblado. Por ejemplo, en el siguiente código se comprueba que la siguiente instrucción a ensamblar no ocupara una posición de memoria superior al inicio del a memoria de vídeo (0xC000 en el Amstrad CPC).

```
ASSERT @<0xC000
```

### DB, DM, DEFB, DEFM 

- DEFB  n [,n ...]
- DEFM  n [,n ...]
- DB    n [,n ...]
- DM    n [,n ...]

Almacena en la posición actual de memoria la lista de bytes suministrada como parámetro. *n* puede ser un número o una expresión numérica en el rango de 0 a 255 (0x00 a 0xFF).

```
DB 0xFF, 0xFF, 0xFF, 0xFF
```

Es posible utilizar también una cadena de texto como parámetro y combinarla con el formato anterior. En ese caso, se almacenarán los códigos ASCII de cada letra como si hubieran sido los valores numéricos suministrados.

```
DB "Hola Mundo",0x00
```

### DS, DEFS, RMEM

- DEFS  n
- DS    n
- RMEM  n

Reserver *n* bytes de memoria. Básicamente, la posición actual de memoria se incrementa en n bytes, dejándola libre para su uso posterior.

### DW, DEFW

- DEFW  n [,n ...]
- DW    n [,n ...]

Almacena *palabras* (dos bytes en formato little-endian) en la posición de memoria actual. *n* puede ser un número o una expresión numérica en el rango de 0 a 65535 (0x0000 a 0xFFFF).

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

### FOR

- FOR rango, instrucción

Repite una sola instrucción (o directiva) tantas veces como el valor de *rango*.

```
FOR 100, DB 0xFF
```

### IF

- IF condición [ELSEIF condición | ELSE] ENDIF
  
La directiva IF permite que ciertas partes del código se tengan en cuenta o sean ignoradas, dependiendo del valor de una expresión lógica. Dicha expresión puede contener símbolos y valores numéricos. Si la expresión es verdadera (distinta de cero), el ensamblador procesará las líneas que siguen a la directiva IF. Si es falsa (igual a cero), esas líneas serán ignoradas.

Una estructura básica de IF podría ser la siguiente:

```
IF expresión
    ; Código ensamblado si la expresión es verdadera
ELSE
    ; Código ensamblado si la expresión es falsa
ENDIF
```

Esta directiva es útil combinada con la opción `--define` de BASM, lo que permite cambiar qué código se ensambla dependiendo de la llamada que se haga al ensamblador. Sin embargo, cualquier símbolo o constante a la que se haga referencia en la expresión lógica debe haber sido declarada con anterioridad.

### INCBIN

- INCBIN "fichero binario"

Esta directiva inserta el contenido del fichero especificado entre comillas dobles. El fichero se debe indicar relativo a la posición del fichero que lo incluye.

```
INCBIN "./assets/mysprite.bin"
```

### LET

- LET símbolo=valor

Esta directiva permite cambiar el valor de un símbolo o constante. Dicho símbolo o constante debe haberse definido inicialmente con LET.

```
LET PADDING=0x00
<código>
LET PADDING=0xFF
<más código>
```

### READ

- READ "fichero de código fuente"

Esta directiva inserta el contenido del fichero especificado entre comillas dobles y lo ensambla. El fichero se debe indicar relativo a la posición del fichero que lo incluye. Todos los símbolos definidos en el fichero que se inserta son globales, por lo que deben ser únicos y no repetirse ni en el fichero principal ni en ninguno otro que se incluya mediante este método.

```
READ "./lib/keyboard.asm"
```

### ORG

- ORG <dirección de memoria>

Especifica la dirección en memoria que debe considerarse como la actual a partir de ese momento para cualquier cálculo necesario como, por ejemplo, establecer el valor de una etiqueta. Un código fuente puede contener más de una ocurrencia de esta directiva.

```
ORG 0x4000
```

### PRINT

- PRINT expresión[, expresión ...]

Imprime en la salida estándar el resultado de la expresión suministrada como parámetro tan pronto como es evaluada durante el ensamblado. Puede resultar útil para generar información adicional durante el ensablado, por ejemplo, la memoria total que consume nuestro programa.

```
ORG 0x4000
<código>
PRINT @-0x4000
```

## Expresiones y carácteres especiales

Siempre que una instrucción o directiva requiera un número como parámetro, se puede utilizar una expresión matemática en su lugar. Estas expresiones pueden hacer referencia a cualquier símbolo definido en el código. Si el resultado de una expresión es negativo, se usa su complemento a dos como valor. Además, algunos símbolos tienes un significado especial, tal y como se recoge en la siguiente lista:

- **$** representa la dirección en memoria para la instrucción actual
- **@** equivalente e intercambiable con el símbolo **$**
- **&** prefijo para indicar números hexadecimales (&FF)
- **0x** prefijo para indicar números hexadecimales (0xFF)
- **%** prefijo para indicar números binarios (%11111111)
- **0b** prefijo para indicar números binarios (0b11111111)
- **"** las comillas dobles delimitan carácteres o cadenas de texto
- **'** las comillas son equivalentes a las comillas dobles.

Un solo carácter entre comillas puede utilizarse para representar el valor ASCII (un byte) de dicho carácter en expresiones numéricas. Sin embargo, ni las comillas dobles ni las simples pueden aparecer como parte de la cadena de texto.







