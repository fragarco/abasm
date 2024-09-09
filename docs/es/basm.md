# Introducción

BASM es un ensamblador cruzado diseñado específicamente para la plataforma Amstrad CPC y su CPU Z80. Desarrollado en Python 3, su principal objetivo es proporcionar una herramienta ligera y altamente portable para programadores interesados en crear código ensamblador para esta clásica plataforma de 8 bits. Al no depender de librerías externas ni herramientas de terceros, BASM puede ejecutarse en cualquier sistema que cuente con un intérprete de Python 3. Además, el proyecto incluye otras herramientas, también programadas en Python y sin dependencias, para empaquetar el resultado del ensamblador en archivos DSK o CDT.

BASM está basado en el fantástico proyecto pyZ80, creado inicialmente por Andrew Collier y modificado posteriormente por Simon Owen.

## ¿Por qué otro ensamblador para Amstrad?

BASM surge de la idea de contar con una herramienta portable y fácil de modificar por cualquiera, sin depender de sistemas operativos específicos o entornos de desarrollo particulares. Uno de sus objetivos es proporcionar una sintaxis compatible con el antiguo ensamblador MAXAM, con la sintaxis de WinAPE y con la de Virtual Machine Simulator. De esta forma, los desarrolladores pueden contar con varias opciones para depurar su código durante el desarrollo.

En cualquier caso, si lo que buscas es eficiencia en vez de portabilidad y facilidad de modificación, quizás quieras probar estos otros ensambladores:

* [Pasmo](https://pasmo.speccy.org/)
* [ASZ80](https://shop-pdp.net/ashtml/)
* [Rasm](https://github.com/EdouardBERGE/rasm)

# Uso básico

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
# Sintaxis

La sintaxis de BASM trata de asemejarle lo máximo posible a la del ensamblador MAXAM. Dicha sintaxis es bastante compatible con la soportada por el simulador WinAPE. Además, BASM soporta algunas variaciones que también lo hacen compatible con la sintaxis utilizada por el simulador Retro Virtual Machine.

El objetivo de esto es permitir que los desarrolladores que usen BASM dispongan de herramientas para la depuración y prueba de sus programas.

A continuación, se muestra un ejemplo sencillo de programa escrito empleando la sintaxis de BASM. Dicho ejemplo muestra tres de los elementos básicos de cualquier programa escrito en ensamblador: etiquetas, instrucciones y comentarios. Un cuarto elemento serían las directivas del ensamblador, comandos que BASM interpreta para fijar la dirección inicial de carga o el formato en el que ciertos datos deben cargarse en memoria. En este capítulo también se repasará el listado completo de directivas soportadas.

Un aspecto importante y común a los cuatro elementos es que BASM no discrimina entre mayúsculas y minúsculas. Por tanto, 'LD A,32' y 'ld a,32' producen el mismo resultado. Lo mismo se aplica a las etiquetas: 'main', 'MAIN' o 'Main' que BASM considerará como la misma etiqueta.

``` asm
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

## Comentarios

Los comentarios en código ensamblador son anotaciones escritas por el programador que no serán interpretadas ni ejecutadas por la CPU. Su propósito es proporcionar información adicional sobre el código para hacerlo más comprensible y mantenible.

Los comentarios son importantes en cualquier lenguaje de programación, pero en ensamblador adquieren una importancia aún mayor, ya que debido al bajo nivel de abstracción del lenguaje ensamblador, el código no suele ser sencillo de interpretar. Por tanto, son cruciales para explicar su propósito y funcionamiento

Como norma general, se recomienda hacer uso de los comentarios para:

- Describir partes del código complejas, explicando qué hace una secuencia de instrucciones particular o los parámetros y valor que devuelve una subrutina.
- Delimitar secciones del código, como bucles, funciones o bloques lógicos.
- Proporcionar contexto, indicando el propósito de una variable, etiqueta o constante.

En BASM, los comentarios suelen indicarse con el caracter ';' (punto y coma). Cuando BASM encuentra dicho caracter, procede a ignorar el resto de la línea.

```
; Esto es un comentario
; Esto es otro comentario
```

## Etiquetas

Las etiquetas en el código ensamblador son nombres simbólicos que se utilizan para marcar una posición específica en el programa, como una dirección de memoria o una instrucción. Su propósito principal es facilitar la navegación dentro del código y hacer referencias a esa posición sin tener que usar direcciones de memoria concretas. Sus usos principales serían:

En saltos y bucles: Las etiquetas se usan como destinos en instrucciones de salto (JMP, JE, etc.), permitiendo redirigir el flujo de ejecución a una parte específica del programa.

En la manipulación de datos: Se utilizan para referirse a variables o datos en memoria, facilitando su acceso y manipulación.

Modularidad: Ayudan a hacer el código más legible y fácil de mantener al dar nombres descriptivos a secciones importantes del programa.

## Instrucciones

Las instrucciones son operaciones que debe realizar la CPU (el procesador Z80 en nuestro caso). El proceso de ensamblar consiste en generar el código binario correspondiente a dichas instrucciones. Cada instrucción suele estar compuesta por un *opcode* y sus *operandos*.

Un opcode (abreviatura de operation code o código de operación) es la parte de una instrucción que especifica la acción que debe realizar la CPU. Es un valor binario o hexadecimal único asociado a una operación particular, como sumar, restar, cargar un valor en un registro, o realizar una comparación. Por tanto, el opcode indica a la CPU qué operación ejecutar, mientras que los operandos (si los hay) proporcionan los datos necesarios para dicha operación. Por ejemplo:

```
ld a,32
```

El *opcode* sería 'ld a' mientras que el operando sería '32'. El significado del opcode es 'carga en el registro A', mientras que el valor a cargar sería directamente el número 32.

La explicación de todos los opcodes soportados por el procesador Z80 queda fuera del alcance de este manual. Sin embargo, el lector interesado puede consultar cualquiera de los siguientes recursos:

- [Tabla resumen de los opcodes soportados por el Z80](https://clrhome.org/table)
- [Z80 Heaven](http://z80-heaven.wikidot.com/)
- [Manual oficial del Z80](https://www.zilog.com/docs/z80/um0080.pdf)

## Directivas del ensamblador

Una directiva de ensamblador es una instrucción que no se traduce directamente en código máquina, sino que proporciona información o instrucciones al ensamblador sobre cómo procesar el código fuente. Estas directivas controlan aspectos del proceso de ensamblado, como la organización del código, la definición de datos, la asignación de memoria y la definición de constantes. A diferencia de las instrucciones que se ejecutan en la CPU, las directivas solo afectan al ensamblador durante el ensamblado del código fuente. Ejemplos comunes incluyen ORG (para establecer la dirección de inicio), EQU (para definir constantes) o DB (para definir datos en memoria). La lista completa de directivas soportadas por BASM y su significado es el siguiente:

## Símbolos especiales





