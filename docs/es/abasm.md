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
python3 abasm.py <program.asm> [opciones]
```

Este comando ensamblará el archivo `program.asm` y generará un fichero binario con el mismo nombre, `program.bin`.

## Opciones disponibles

- `-d` o `--define`: Permite definir pares `SÍMBOLO=VALOR`. Dichos símbolos pueden utilizarse en el código como constantes o etiquetas. Esta opción se puede emplear múltiples veces para definir varios símbolos.
- `--start`: Define la dirección de memoria que se tomará como punto de inicio para la carga del programa. Por defecto, esta dirección es `0x4000`, aunque también puede establecerse directamente dentro del código usando la directiva `ORG`.
- `-o` o `--output`: Especifica el nombre del archivo binario de salida. Si no se utiliza esta opción, se empleará el nombre del archivo de entrada cambiando su extensión por `.bin`.

## Ejemplos de uso

Definir una constante utilizada en el código:

```
python3 abasm.py program.asm -d MY_CONSTANT=100
```

Establecer el nombre exacto del archivo binario ensamblado:

```
python3 abasm.py program.asm -o output.bin
```

Establecer la dirección de inicio en memoria que debe considerarse para el cálculo de los saltos y otras referencias relativas utilizadas en el código fuente, por ejemplo, a `0x2000`:

```
python3 abasm.py program.asm --start 0x2000
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
000001  4000               	org  0x4000
000002  4000               	main
000003  4000  3E FF        	ld   a, 0xFF
000004  4002  32 00 C0     	ld  (0xC000), a
000005  4005               	endloop
000006  4005  C3 05 40     	jp endloop
```

La primera columna indica el número secuencial de la instrucción en el archivo de código fuente. La segunda columna indica qué posición de memoria debe ocupar el código generado (si se ha generado alguno, ya que algunas directivas y etiquetas no generan código binario). La tercera columna muestra el código binario resultante de ensamblar la instrucción, y la última columna la instrucción original.

## Archivo de símbolos

ABASM también genera un listado de todos los símbolos encontrados y su valor asociado. La mayoría de ellos serán etiquetas utilizadas para marcar posiciones de salto o ubicaciones de memoria donde se han almacenado ciertos datos.

La extensión de este archivo es `.MAP` y su formato es el de un diccionario de Python. Esto permite emplear el archivo en otras utilidades (como los empaquetadores DSK y CDT) y utilizar los símbolos en lugar de sus valores. En la documentación sobre las utilidades DSK y CDT se puede encontrar un ejemplo de uso de este archivo.

```
# Lista de símbolos en formato de diccionario de Python
# Símbolo: [dirección, número total de apariciones]
{
	"ENDLOOP": [0x4005, 2],
	"MAIN": [0x4000, 1],
}
```

# Sintaxis

La sintaxis de ABASM está diseñada para asemejarse lo máximo posible a la del ensamblador MAXAM. Esta sintaxis es bastante compatible con la soportada por el simulador WinAPE. Además, ABASM admite algunas variaciones que también lo hacen compatible con la sintaxis utilizada por el simulador Retro Virtual Machine. El objetivo es permitir que los desarrolladores que usen ABASM cuenten con varias herramientas para la depuración y prueba de sus programas.

A continuación se muestra un ejemplo sencillo de un programa escrito utilizando la sintaxis de ABASM. Este ejemplo muestra tres de los elementos básicos de cualquier programa escrito en ensamblador: etiquetas, instrucciones y comentarios. Un cuarto elemento serían las directivas del ensamblador, comandos dirigidos al propio ABASM en lugar de al procesador Z80. En este capítulo también repasaremos el listado completo de directivas soportadas.

Un aspecto importante y común a los cuatro elementos es que ABASM no discrimina entre mayúsculas y minúsculas. Por lo tanto, 'LD A,32' y 'ld a,32' producen el mismo resultado. Lo mismo se aplica a las etiquetas: 'main', 'MAIN' o 'Main' se consideran la misma etiqueta.

```
; Imprime todos los caracteres ASCII entre el código 32 y 128.
; Es una variación del primer ejemplo presentado en el
; manual de MAXAM

.main             ; define una etiqueta 'main'
    ld a,32       ; primer código de letra ASCII en el acumulador

.loop             ; define una etiqueta 'loop'
    call &BB5A    ; LLAMA a txt_output, la rutina de salida del firmware
    inc  a        ; pasa al siguiente carácter
    cp   128      ; ¿hemos terminado con todos?
    jr   c,loop   ; no - regresa para procesar el siguiente

.end  
    jp   end      ; bucle infinito usado como punto final del programa

```

Otro aspecto importante es que ABASM ignora el símbolo '.' al principio de las etiquetas. Una vez más, el objetivo es soportar la mayor cantidad posible de dialectos de ensamblador. De esta forma, .MAIN y MAIN serían la misma etiqueta.

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

Todas las etiquetas son globales en ABASM, lo que significa que deben ser únicas sin importar cuántos archivos dividan el código fuente.

## Instrucciones

Las instrucciones son operaciones que debe realizar la CPU (el procesador Z80 en nuestro caso). El proceso de ensamblar consiste en generar el código binario correspondiente a estas instrucciones. Cada instrucción suele estar compuesta por un *opcode* y sus *operandos*.

Un opcode (abreviatura de "operation code" o código de operación) es la parte de una instrucción que especifica la acción que debe realizar la CPU. Es un valor binario o hexadecimal único asociado a una operación particular, como sumar, restar, cargar un valor en un registro o realizar una comparación. Por lo tanto, el opcode determina la operación a ejecutar, mientras que los operandos (si los hay) proporcionan los datos necesarios para dicha operación. Por ejemplo:

```
ld a,32
```

El *opcode* sería 'ld a', mientras que el operando sería '32'. El significado del opcode es 'cargar en el registro A', mientras que el valor a cargar sería directamente el número 32.

La explicación de todos los opcodes soportados por el procesador Z80 queda fuera del alcance de este manual. Sin embargo, el lector interesado puede consultar cualquiera de los siguientes recursos:

- [Tabla resumen de los opcodes soportados por el Z80](https://clrhome.org/table)
- [Z80 Heaven](http://z80-heaven.wikidot.com/)
- [Manual oficial del Z80](https://www.zilog.com/docs/z80/um0080.pdf)

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

### FOR

- FOR rango, instrucción

Repite una sola instrucción (o directiva) tantas veces como el valor de *rango*.

```
FOR 100, DB 0xFF
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

Esta directiva permite asignar un nombre o símbolo a un bloque de código que se extiende hasta la siguiente ocurrencia de ENDM. La macro puede incluir una lista de parámetros que serán sustituidos por los valores proporcionados en futuras *llamadas* a la macro. Una vez definida, una macro puede utilizarse en el resto del código como si fuera una instrucción convencional.

```
macro get_screenPtr REG, X, Y 
   ld REG, &C000 + 80 * (Y / 8) + 2048 * (Y & 7) + X 
endm

main:
   get_screenPtr hl, 20, 10
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

### READ

- READ "fichero de código fuente"

Esta directiva inserta el contenido del fichero especificado entre comillas dobles y lo ensambla. La ruta del fichero debe ser relativa a la ubicación del fichero que lo incluye. Todos los símbolos definidos en el fichero insertado son globales, por lo que deben ser únicos y no repetirse en el fichero principal ni en ningún otro fichero incluido mediante este método.

```
READ "./lib/keyboard.asm"
```

### ORG

- ORG <dirección de memoria>

Especifica la dirección de memoria que debe considerarse como la actual a partir de ese momento para cualquier cálculo necesario, como establecer el valor de una etiqueta. Lo habitual es que esta directiva aparezca como la primera instrucción del código fuente.

Sin embargo, no hay nada que impida incluir más de una ocurrencia de esta directiva en el código fuente, aunque no es recomendable, ya que el fichero binario resultante no contendrá nada entre la posición anterior y la siguiente instrucción ensamblada tras la directiva. Además, las utilidades DSK o CDT no pueden posicionar partes del fichero resultante en diferentes áreas de la memoria. Por lo tanto, si un programa necesita tener partes cargadas en diferentes áreas de la memoria, es aconsejable generar un fichero binario independiente para cada área y empaquetarlos todos dentro del mismo DSK o CDT, junto con un cargador programado en BASIC (por ejemplo).

```
ORG 0x4000
```

### PRINT

- PRINT expresión[, expresión ...]

Imprime el resultado de la(s) expresión(es) proporcionada(s) en la salida estándar tan pronto como se evalúe durante el ensamblado. Esto puede ser útil para generar información adicional durante el ensamblado, como la memoria total que consume el programa.

```
ORG 0x4000
<código>
PRINT @-0x4000
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






