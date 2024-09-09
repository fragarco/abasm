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
