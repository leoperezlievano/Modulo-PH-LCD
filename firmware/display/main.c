/*- Includes ---------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "soc-hw.h"

/*- Definitions ------------------------------------------------------------*/
#ifndef UART_COMMANDS_BUFFER_SIZE
#define UART_COMMANDS_BUFFER_SIZE 100
#endif

#define FINALCHARACTER1 '\r'
#define FINALCHARACTER2 '\n'

/*- Variables --------------------------------------------------------------*/

void nivelpH(uint8_t rojo, uint8_t azul, uint8_t verde, uint8_t posx, uint8_t posy){
	
	uint8_t bandera = 0;
	set_position(posx, posy);
	
	if(((rojo >= 22) && (rojo <= 24)) && ((azul >= 18) && (azul <= 20)) && ((verde >= 24) && (verde <= 26))){		//5.8 - 6.2
		print_char(21);
		print_char(14);
		print_char(24);
		print_char(13);
		print_char(22);
		print_char(14);
		print_char(18);
		bandera = 1;
	}
	if(((rojo >= 20) && (rojo <= 24)) && ((azul >= 17) && (azul <= 21)) && ((verde >= 20) && (verde <= 23))){		//6.6 - 7.0
		print_char(22);
		print_char(14);
		print_char(22);
		print_char(13);		
		print_char(23);
		print_char(14);
		print_char(16);
		bandera = 1;
	}
	if(((rojo >= 17) && (rojo <= 20)) && ((azul >= 14) && (azul <= 18)) && ((verde >= 15) && (verde <= 17))){		//7.4 - 7.8
		print_char(23);
		print_char(14);
		print_char(20);
		print_char(13);
		print_char(23);
		print_char(14);
		print_char(24);
		bandera = 1;
	}	
	if(((rojo >= 15) && (rojo <= 16)) && ((azul >= 17) && (azul <= 18)) && ((verde >= 15) && (verde <= 16))){		//8.0 - 8.2
		print_char(24);
		print_char(14);
		print_char(16);
		print_char(13);
		print_char(24);
		print_char(14);
		print_char(18);
		bandera = 1;
	}
	if(bandera == 0){
		print_cadena_ascii("X.X");
	}	
}

int main(void){	
	sec_on_display();
	clear_GDRAM();   
        set_position(4,2);
        print_cadena_ascii("Color rojo: ");
        set_position(4,3);
        print_cadena_ascii("Color azul: ");
        set_position(4,4);
        print_cadena_ascii("Color verde: ");
        set_position(4,6);
        print_cadena_ascii("Nivel de pH: ");
        
        uint32_t rojo, azul, verde;
        
        on_led();
        
        while(1){
		//mSleep(3000);
		initPH(); 			//Lectura de color en el sensor de pH
		habilitar_PH_sensor();
		rojo = leer_rojo();
		azul = leer_azul();
		verde = leer_verde();
		
		set_position(80,2);
		print_char(00);
		print_char(00);
		print_char(00);
		set_position(80,2);
		print_entero_ascii(rojo);
		set_position(80,3);
		print_char(00);
		print_char(00);
		print_char(00);
		set_position(80,3);
		print_entero_ascii(azul);
		set_position(80,4);
		print_char(00);
		print_char(00);
		print_char(00);
		set_position(80,4);
		print_entero_ascii(verde);
		
		nivelpH(rojo, azul, verde, 80, 6);
		              
		mSleep(100);
        };
   
        	
    	return 0;
}
