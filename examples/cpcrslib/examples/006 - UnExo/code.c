
#include <test.h>

#include "data_exo.h"
/*
0. Compress binary file with exo: exo.bat filein fileout  ej: exo tonteria.bin tonteria.exp
1. Convert tonteria.exp to tonteria.h:   bin2c.exe -o tonteria.h tonteria.p
2. Convert tonteria.h to data_exo.h (manual process in an text editor)

*/
main() {


	cpc_SetModo(1);
	cpc_UnExo(image,#0xc000);

    while(1);


}
