# Amstrad CPC Basic Assembler (ABASM)

## Español:

ABASM es un ensamblador cruzado enfocado en la plataforma Amstrad CPC. Está escrito en Python 3, sin dependencias externas, de forma que sea posible usarlo en cualquier sistema con un soporte mínimo de Python.

Está basado en el proyecto pyz80, creado originalmente por Andrew Collier y posteriormente modificado por Simon Owen. ABASM nació para dar soporte a un compilador de Locomotive BASIC, pero dado que es totalmente funcional, parece tener sentido que sea un proyecto por sí mismo.

Además del ensamblador propiamente dicho, se incluyen utilidades para empaquetar los resultados en archivos DSK o CDT, convertir imágenes PNG o generar scripts sencillos para construir el proyecto. La documentación completa se puede consultar en la carpeta DOCS, disponible tanto en inglés como en español.

 * [Manual del ABASM](docs/es/abasm.md)
 * [Manual de la utilidad DSK](docs/es/dsk.md)
 * [Manual de la utilidad CDT](docs/es/cdt.md)
*  [Manual de la utilidad IMG](docs/es/img.md)
*  [Manual de la utilidad ASMPRJ](docs/es/asmprj.md)
*  [Manual de la utilidad BINDIFF](docs/es/bindiff.md)

ABASM y el conjunto de utilidades que incluye son software libre; puedes redistribuirlo y/o modificarlo bajo los términos de la General Public License de GNU en su versión 3, tal como fue publicada por la Free Software Foundation.

Este paquete se distribuye con la esperanza de que sea útil, pero SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita de COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Consulta la General Public License de GNU para más detalles (en el archivo LICENSE).

Además, `ABASM` distribuye adaptaciones de las bibliotecas `CPCRSLIB` y `CPCTELERA` através de sus propias licencias. Consulta los detalles de cada una en src/lib/cpcrslib y src/lib/cpctelera.

## English:

ABASM is a cross-assembler focused on the Amstrad CPC platform. It is written in Python 3 without external dependencies, making it possible to use on any system with minimal Python support.

It is based on the pyz80 project, originally created by Andrew Collier and later modified by Simon Owen. ABASM was initially created to support a Locomotive BASIC compiler, but since it is fully functional, it makes sense for it to be a standalone project.

In addition to the assembler itself, several utilities are included to package the results into DSK or CDT files, create simple building scripts or process PNG images files. The complete documentation can be found in the DOCS folder, available in both English and Spanish.

 * [ABASM Manual](docs/en/abasm.md)
 * [DSK Utility Manual](docs/en/dsk.md)
 * [CDT Utility Manual](docs/en/cdt.md)
 * [IMG Utility Manual](docs/en/img.md)
 * [ASMPRJ Utility Manual](docs/en/asmprj.md)
 * [BINDIFF Utility Manual](docs/en/bindiff.md)

ABASM and all included utilities are free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation in its version 3.

This package is distributed in the hope that it will be useful but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details (file LICENSE).

Finally, `ABASM` distributes special versions of `CPCRSLIB` and `CPCTELERA` libraries under their own licenses. Check out all the license details in src/lib/cpcrslib and src/lib/cpctelera directories.
