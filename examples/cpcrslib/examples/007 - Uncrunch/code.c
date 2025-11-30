#include <test.h>

#include "data_pu.h"

/*
0. Compress binary file with pucrunch: pucrunch -d -c0 filein fileout    ej: pucrunch -d -c0 tonteria.bin tonteria.pu
1. Convert tonteria.pu to tonteria.h:   bin2c.exe -o tonteria.h tonteria.pu
2. Convert tonteria.h to data_pu.h (manual process in an text editor)

*/


main() {

	
	cpc_SetModo(1);
	cpc_Uncrunch(image,#0xc000);

    while(1); 
	
		
}
