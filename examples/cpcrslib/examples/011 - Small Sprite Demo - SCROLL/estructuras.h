typedef	struct {		// minimun sprite structure
	   	char *sp0;		//2 bytes 	01
	   	char *sp1;		//2 bytes	23
	   	int coord0;		//2 bytes	45	current superbuffer address
	   	int coord1;		//2 bytes	67  old superbuffer address
	   	unsigned char cx, cy;	//2 bytes 89 	current coordinates
	   	unsigned char ox, oy;	//2 bytes 1011  old coordinates
	   	unsigned char visible;
	   	unsigned char move;		// 	in this example, to know the movement direction of the sprite  0 left, 1 right 2 up, 3 down
		unsigned char tipo, desaparece;

   	} DISPARO;
   	DISPARO disparo [6];
   	DISPARO edisparo [6];



typedef	struct {		// minimun sprite structure
	   	char *sp0;		//2 bytes 	01
	   	char *sp1;		//2 bytes	23
	   	int coord0;		//2 bytes	45	current superbuffer address
	   	int coord1;		//2 bytes	67  old superbuffer address
	   	 char cx, cy;	//2 bytes 89 	current coordinates
	   	 char ox, oy;	//2 bytes 1011  old coordinates
	   	unsigned char visible;
	   	unsigned char move;		// 	in this example, to know the movement direction of the sprite
	   	unsigned char vx;	// coordenadas virtuales
	   	unsigned char posicion,modo;
		unsigned char desaparece;
		unsigned char tipo;
		unsigned char frame;
		unsigned char num;
		unsigned char dir;
		unsigned char vida;

   	} NAVE;
   	NAVE sprite, nave,  sprite00,sprite01,sprite02;


